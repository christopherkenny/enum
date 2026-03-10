#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include <stdlib.h>
#include <string.h>

/* -----------------------------------------------------------------------
 * BFS helper: find connected-component sizes among zero-vertices of `vec`.
 * adj_ptr/adj_data: CSR adjacency list (0-indexed vertices).
 * bad_holes/n_bad: forbidden component sizes.
 * Returns 1 if valid (no bad holes), 0 if a bad-hole component exists.
 * queue must be a pre-allocated int buffer of length >= n_vertices.
 * visited must be a pre-allocated int buffer of length >= n_vertices,
 * zeroed before the call (and is left dirty after — caller re-zeroes it).
 * ----------------------------------------------------------------------- */
static int bfs_no_bad_holes(
    const int *vec, int n_vertices,
    const int *adj_ptr, const int *adj_data,
    const int *bad_holes, int n_bad,
    int *queue, int *visited
) {
    for (int start = 0; start < n_vertices; start++) {
        if (vec[start] != 0 || visited[start]) continue;

        int head = 0, tail = 0, comp_size = 0;
        queue[tail++] = start;
        visited[start] = 1;

        while (head < tail) {
            int v = queue[head++];
            comp_size++;
            for (int k = adj_ptr[v]; k < adj_ptr[v + 1]; k++) {
                int u = adj_data[k];
                if (vec[u] == 0 && !visited[u]) {
                    visited[u] = 1;
                    queue[tail++] = u;
                }
            }
        }

        for (int i = 0; i < n_bad; i++) {
            if (comp_size == bad_holes[i]) return 0;
        }
    }
    return 1;
}

/* -----------------------------------------------------------------------
 * C_build_conflicts
 *
 * Arguments (all SEXP, passed via .Call):
 *   ominos_mat  : integer matrix (total x n_ominos), column-major
 *   bad_holes   : integer vector of forbidden component sizes
 *   adj_ptr     : integer vector (length total+1), CSR row pointers, 0-indexed
 *   adj_data    : integer vector, CSR column indices, 0-indexed
 *   total_sexp  : scalar integer, number of vertices
 *   n_ominos_sexp: scalar integer, number of ominos (columns in ominos_mat)
 *
 * Returns a named list:
 *   $ominos  : integer matrix (total x n_valid), filtered ominos
 *   $fd_ptr  : integer vector (length total+1)  first_dict CSR ptr
 *   $fd_data : integer vector, first_dict CSR data (0-indexed omino indices)
 *   $cp_ptr  : integer vector (length n_valid+1) compatible CSR ptr
 *   $cp_data : integer vector, compatible CSR data (0-indexed omino indices)
 * ----------------------------------------------------------------------- */
SEXP C_build_conflicts(
    SEXP ominos_mat,
    SEXP bad_holes_sexp,
    SEXP adj_ptr_sexp,
    SEXP adj_data_sexp,
    SEXP total_sexp,
    SEXP n_ominos_sexp
) {
    int total    = INTEGER(total_sexp)[0];
    int n_ominos = INTEGER(n_ominos_sexp)[0];
    int n_bad    = LENGTH(bad_holes_sexp);
    const int *ominos    = INTEGER(ominos_mat);
    const int *bad_holes = INTEGER(bad_holes_sexp);
    const int *adj_ptr   = INTEGER(adj_ptr_sexp);
    const int *adj_data  = INTEGER(adj_data_sexp);

    int *queue   = (int *)R_alloc(total, sizeof(int));
    int *visited = (int *)R_alloc(total, sizeof(int));
    int *combined = (int *)R_alloc(total, sizeof(int));

    /* ---- Step 1: filter ominos by single-omino hole check ---- */
    int *valid = (int *)R_alloc(n_ominos, sizeof(int));
    int n_valid = 0;

    for (int i = 0; i < n_ominos; i++) {
        const int *om = ominos + (long)i * total;
        memset(visited, 0, total * sizeof(int));
        valid[i] = bfs_no_bad_holes(om, total, adj_ptr, adj_data,
                                    bad_holes, n_bad, queue, visited);
        if (valid[i]) n_valid++;
    }

    /* Build mapping: old omino index -> new (compressed) index */
    int *new_idx = (int *)R_alloc(n_ominos, sizeof(int));
    int cnt = 0;
    for (int i = 0; i < n_ominos; i++) {
        new_idx[i] = valid[i] ? cnt++ : -1;
    }

    /* ---- Step 2: build first_dict (CSR) ----
     * first_dict[v] = list of new omino indices whose lowest 1-bit is v.
     * We build counts first, then fill. */
    int *fd_count = (int *)R_alloc(total, sizeof(int));
    memset(fd_count, 0, total * sizeof(int));

    /* first_one for each valid omino */
    int *fo = (int *)R_alloc(n_valid, sizeof(int));  /* first-one vertex */
    int vi = 0;
    for (int i = 0; i < n_ominos; i++) {
        if (!valid[i]) continue;
        const int *om = ominos + (long)i * total;
        int fv = 0;
        while (fv < total && om[fv] == 0) fv++;
        fo[vi] = fv;
        if (fv < total) fd_count[fv]++;
        vi++;
    }

    SEXP fd_ptr_sexp = PROTECT(allocVector(INTSXP, total + 1));
    int *fd_ptr = INTEGER(fd_ptr_sexp);
    fd_ptr[0] = 0;
    for (int v = 0; v < total; v++) fd_ptr[v + 1] = fd_ptr[v] + fd_count[v];

    SEXP fd_data_sexp = PROTECT(allocVector(INTSXP, fd_ptr[total]));
    int *fd_data = INTEGER(fd_data_sexp);
    memset(fd_count, 0, total * sizeof(int));  /* reuse as cursor */
    for (int ni = 0; ni < n_valid; ni++) {
        int fv = fo[ni];
        if (fv < total) {
            fd_data[fd_ptr[fv] + fd_count[fv]] = ni;
            fd_count[fv]++;
        }
    }

    /* ---- Step 3: build compatible (CSR) ----
     * Two passes: first count, then fill. */
    int *cp_count = (int *)R_alloc(n_valid, sizeof(int));
    memset(cp_count, 0, n_valid * sizeof(int));

    /* Collect pairs first into a temporary array (upper triangle only) */
    /* Worst case n_valid*(n_valid-1)/2 pairs, but we use a two-pass approach */

    /* Pass 1: count compatible pairs per omino */
    /* We iterate over valid omino pairs using old indices */
    /* Map old -> new is in new_idx[]. Iterate valid pairs directly. */

    /* Build a list of valid old indices for fast iteration */
    int *valid_old = (int *)R_alloc(n_valid, sizeof(int));
    vi = 0;
    for (int i = 0; i < n_ominos; i++) {
        if (valid[i]) valid_old[vi++] = i;
    }

    for (int ai = 0; ai < n_valid - 1; ai++) {
        const int *om_a = ominos + (long)valid_old[ai] * total;
        for (int bi = ai + 1; bi < n_valid; bi++) {
            const int *om_b = ominos + (long)valid_old[bi] * total;
            /* Check overlap */
            int overlap = 0;
            for (int v = 0; v < total; v++) {
                if (om_a[v] + om_b[v] > 1) { overlap = 1; break; }
            }
            if (overlap) continue;
            /* Build combined, check holes */
            for (int v = 0; v < total; v++) combined[v] = om_a[v] + om_b[v];
            memset(visited, 0, total * sizeof(int));
            if (bfs_no_bad_holes(combined, total, adj_ptr, adj_data,
                                 bad_holes, n_bad, queue, visited)) {
                cp_count[ai]++;
                cp_count[bi]++;
            }
        }
    }

    SEXP cp_ptr_sexp = PROTECT(allocVector(INTSXP, n_valid + 1));
    int *cp_ptr = INTEGER(cp_ptr_sexp);
    cp_ptr[0] = 0;
    for (int ni = 0; ni < n_valid; ni++) cp_ptr[ni + 1] = cp_ptr[ni] + cp_count[ni];

    SEXP cp_data_sexp = PROTECT(allocVector(INTSXP, cp_ptr[n_valid]));
    int *cp_data = INTEGER(cp_data_sexp);

    /* Pass 2: fill cp_data */
    memset(cp_count, 0, n_valid * sizeof(int));
    for (int ai = 0; ai < n_valid - 1; ai++) {
        const int *om_a = ominos + (long)valid_old[ai] * total;
        for (int bi = ai + 1; bi < n_valid; bi++) {
            const int *om_b = ominos + (long)valid_old[bi] * total;
            int overlap = 0;
            for (int v = 0; v < total; v++) {
                if (om_a[v] + om_b[v] > 1) { overlap = 1; break; }
            }
            if (overlap) continue;
            for (int v = 0; v < total; v++) combined[v] = om_a[v] + om_b[v];
            memset(visited, 0, total * sizeof(int));
            if (bfs_no_bad_holes(combined, total, adj_ptr, adj_data,
                                 bad_holes, n_bad, queue, visited)) {
                cp_data[cp_ptr[ai] + cp_count[ai]] = bi;
                cp_count[ai]++;
                cp_data[cp_ptr[bi] + cp_count[bi]] = ai;
                cp_count[bi]++;
            }
        }
    }

    /* ---- Build output ominos matrix (total x n_valid) ---- */
    SEXP ominos_out = PROTECT(allocMatrix(INTSXP, total, n_valid));
    int *out = INTEGER(ominos_out);
    vi = 0;
    for (int i = 0; i < n_ominos; i++) {
        if (!valid[i]) continue;
        memcpy(out + (long)vi * total,
               ominos + (long)i * total,
               total * sizeof(int));
        vi++;
    }

    /* ---- Assemble return list ---- */
    const char *names[] = {"ominos", "fd_ptr", "fd_data", "cp_ptr", "cp_data", ""};
    SEXP result = PROTECT(mkNamed(VECSXP, names));
    SET_VECTOR_ELT(result, 0, ominos_out);
    SET_VECTOR_ELT(result, 1, fd_ptr_sexp);
    SET_VECTOR_ELT(result, 2, fd_data_sexp);
    SET_VECTOR_ELT(result, 3, cp_ptr_sexp);
    SET_VECTOR_ELT(result, 4, cp_data_sexp);

    UNPROTECT(6);
    return result;
}

/* -----------------------------------------------------------------------
 * Recursive backtracking (called by C_run_enumeration)
 * ----------------------------------------------------------------------- */
typedef struct {
    const int *ominos;        /* total x n_ominos, col-major */
    const int *fd_ptr;        /* first_dict CSR ptr */
    const int *fd_data;       /* first_dict CSR data, 0-indexed */
    const char *compat_mat;   /* n_ominos x n_ominos boolean */
    int total;
    int n_ominos;
    int num_parts;
    int collect;
    int *plan;                /* plan[num_parts], current choices */
    int *covered;             /* covered[total], 0/1 */
    int *assignment;          /* assignment[total], 1-indexed part (collect only) */
    int *results;             /* dynamic result buffer (collect only) */
    int results_cap;
    int count;
} EnumState;

static void recurs_part(EnumState *s, int plan_len, int covered_count) {
    if (plan_len == s->num_parts) {
        if (covered_count == s->total) {
            s->count++;
            if (s->collect) {
                if (s->count > s->results_cap) {
                    s->results_cap = s->results_cap ? s->results_cap * 2 : 256;
                    s->results = (int *)realloc(
                        s->results,
                        (size_t)s->results_cap * s->total * sizeof(int)
                    );
                    if (!s->results) error("out of memory in C_run_enumeration");
                }
                memcpy(s->results + (long)(s->count - 1) * s->total,
                       s->assignment,
                       s->total * sizeof(int));
            }
        }
        return;
    }

    if (covered_count == s->total) return;

    /* Find first uncovered vertex */
    int fz = 0;
    while (fz < s->total && s->covered[fz]) fz++;

    /* Try each omino that starts at fz */
    for (int k = s->fd_ptr[fz]; k < s->fd_ptr[fz + 1]; k++) {
        int q = s->fd_data[k];

        /* Check compatibility with all current plan members */
        int ok = 1;
        for (int i = 0; i < plan_len; i++) {
            if (!s->compat_mat[(long)s->plan[i] * s->n_ominos + q]) {
                ok = 0;
                break;
            }
        }
        if (!ok) continue;

        /* Add omino q to plan */
        s->plan[plan_len] = q;
        const int *om = s->ominos + (long)q * s->total;
        int newly_covered = 0;
        for (int v = 0; v < s->total; v++) {
            if (om[v]) {
                s->covered[v] = 1;
                if (s->collect) s->assignment[v] = plan_len + 1;
                newly_covered++;
            }
        }

        recurs_part(s, plan_len + 1, covered_count + newly_covered);

        /* Backtrack */
        for (int v = 0; v < s->total; v++) {
            if (om[v]) {
                s->covered[v] = 0;
                if (s->collect) s->assignment[v] = 0;
            }
        }
    }
}

/* -----------------------------------------------------------------------
 * C_run_enumeration
 *
 * Arguments:
 *   ominos_mat    : integer matrix (total x n_ominos), column-major
 *   fd_ptr_sexp   : integer vector (length total+1), 0-indexed
 *   fd_data_sexp  : integer vector, 0-indexed omino indices
 *   cp_ptr_sexp   : integer vector (length n_ominos+1), 0-indexed
 *   cp_data_sexp  : integer vector, 0-indexed omino indices
 *   total_sexp    : scalar integer
 *   n_ominos_sexp : scalar integer
 *   num_parts_sexp: scalar integer
 *   collect_sexp  : scalar logical
 *
 * Returns:
 *   collect=FALSE : ScalarInteger(count)
 *   collect=TRUE  : integer matrix (total x count), or matrix(integer(0), total, 0)
 * ----------------------------------------------------------------------- */
SEXP C_run_enumeration(
    SEXP ominos_mat,
    SEXP fd_ptr_sexp,
    SEXP fd_data_sexp,
    SEXP cp_ptr_sexp,
    SEXP cp_data_sexp,
    SEXP total_sexp,
    SEXP n_ominos_sexp,
    SEXP num_parts_sexp,
    SEXP collect_sexp
) {
    int total     = INTEGER(total_sexp)[0];
    int n_ominos  = INTEGER(n_ominos_sexp)[0];
    int num_parts = INTEGER(num_parts_sexp)[0];
    int collect   = LOGICAL(collect_sexp)[0];

    const int *ominos  = INTEGER(ominos_mat);
    const int *fd_ptr  = INTEGER(fd_ptr_sexp);
    const int *fd_data = INTEGER(fd_data_sexp);
    const int *cp_ptr  = INTEGER(cp_ptr_sexp);
    const int *cp_data = INTEGER(cp_data_sexp);

    /* Build boolean compatibility matrix (n_ominos x n_ominos) */
    char *compat_mat = (char *)R_alloc((size_t)n_ominos * n_ominos, sizeof(char));
    memset(compat_mat, 0, (size_t)n_ominos * n_ominos * sizeof(char));
    for (int i = 0; i < n_ominos; i++) {
        for (int k = cp_ptr[i]; k < cp_ptr[i + 1]; k++) {
            int j = cp_data[k];
            compat_mat[(long)i * n_ominos + j] = 1;
        }
    }

    int *plan       = (int *)R_alloc(num_parts, sizeof(int));
    int *covered    = (int *)R_alloc(total, sizeof(int));
    int *assignment = collect ? (int *)R_alloc(total, sizeof(int)) : NULL;
    memset(covered, 0, total * sizeof(int));
    if (assignment) memset(assignment, 0, total * sizeof(int));

    EnumState s;
    s.ominos      = ominos;
    s.fd_ptr      = fd_ptr;
    s.fd_data     = fd_data;
    s.compat_mat  = compat_mat;
    s.total       = total;
    s.n_ominos    = n_ominos;
    s.num_parts   = num_parts;
    s.collect     = collect;
    s.plan        = plan;
    s.covered     = covered;
    s.assignment  = assignment;
    s.results     = NULL;
    s.results_cap = 0;
    s.count       = 0;

    /* Enumerate: vertex 0 (0-indexed) must be covered first */
    for (int k = fd_ptr[0]; k < fd_ptr[1]; k++) {
        int p = fd_data[k];
        s.plan[0] = p;
        const int *om = ominos + (long)p * total;
        int covered_count = 0;
        for (int v = 0; v < total; v++) {
            if (om[v]) {
                covered[v] = 1;
                if (assignment) assignment[v] = 1;
                covered_count++;
            } else {
                covered[v] = 0;
                if (assignment) assignment[v] = 0;
            }
        }
        recurs_part(&s, 1, covered_count);
        /* covered/assignment reset inside recurs_part on backtrack; but since
         * we set them from scratch each outer iteration, no explicit reset here. */
    }

    SEXP result;
    if (!collect) {
        result = PROTECT(ScalarInteger(s.count));
    } else if (s.count == 0) {
        result = PROTECT(allocMatrix(INTSXP, total, 0));
    } else {
        result = PROTECT(allocMatrix(INTSXP, total, s.count));
        memcpy(INTEGER(result), s.results,
               (size_t)s.count * total * sizeof(int));
    }

    free(s.results);
    UNPROTECT(1);
    return result;
}

/* -----------------------------------------------------------------------
 * Symbol registration
 * ----------------------------------------------------------------------- */
static const R_CallMethodDef call_methods[] = {
    {"C_build_conflicts",  (DL_FUNC)&C_build_conflicts,  6},
    {"C_run_enumeration",  (DL_FUNC)&C_run_enumeration,  9},
    {NULL, NULL, 0}
};

void R_init_enum(DllInfo *dll) {
    R_registerRoutines(dll, NULL, call_methods, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
