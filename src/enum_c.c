#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* -----------------------------------------------------------------------
 * BFS helper: find connected-component sizes among zero-vertices of `vec`.
 * adj_ptr/adj_data: CSR adjacency list (0-indexed vertices).
 * bad_holes/n_bad: forbidden component sizes.
 * Returns 1 if valid (no bad holes), 0 if a bad-hole component exists.
 * queue/visited must be pre-allocated int buffers of length >= n_vertices;
 * visited must be zeroed before the call (left dirty after).
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
 *   ominos_mat   : integer matrix (total x n_ominos), column-major
 *   bad_holes    : integer vector of forbidden component sizes
 *   adj_ptr      : integer vector (length total+1), CSR row pointers, 0-indexed
 *   adj_data     : integer vector, CSR column indices, 0-indexed
 *   total_sexp   : scalar integer, number of vertices
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

    int *queue    = (int *)R_alloc(total, sizeof(int));
    int *visited  = (int *)R_alloc(total, sizeof(int));
    int *combined = (int *)R_alloc(total, sizeof(int));

    /* ---- Step 1: filter ominos by single-omino hole check ---- */
    int *valid = (int *)R_alloc(n_ominos, sizeof(int));
    int n_valid = 0;

    for (int i = 0; i < n_ominos; i++) {
        const int *om = ominos + (size_t)i * total;
        memset(visited, 0, total * sizeof(int));
        valid[i] = bfs_no_bad_holes(om, total, adj_ptr, adj_data,
                                    bad_holes, n_bad, queue, visited);
        if (valid[i]) n_valid++;
    }

    /* ---- Step 2: build first_dict (CSR) ---- */
    int *fd_count = (int *)R_alloc(total, sizeof(int));
    memset(fd_count, 0, total * sizeof(int));

    int *fo = (int *)R_alloc(n_valid > 0 ? n_valid : 1, sizeof(int));
    int vi = 0;
    for (int i = 0; i < n_ominos; i++) {
        if (!valid[i]) continue;
        const int *om = ominos + (size_t)i * total;
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
    memset(fd_count, 0, total * sizeof(int));
    for (int ni = 0; ni < n_valid; ni++) {
        int fv = fo[ni];
        if (fv < total) {
            fd_data[fd_ptr[fv] + fd_count[fv]] = ni;
            fd_count[fv]++;
        }
    }

    /* ---- Step 3: build compatible (CSR), two passes ---- */
    int *cp_count  = (int *)R_alloc(n_valid > 0 ? n_valid : 1, sizeof(int));
    int *valid_old = (int *)R_alloc(n_valid > 0 ? n_valid : 1, sizeof(int));
    memset(cp_count, 0, n_valid * sizeof(int));
    vi = 0;
    for (int i = 0; i < n_ominos; i++) {
        if (valid[i]) valid_old[vi++] = i;
    }

    /* Pass 1: count */
    for (int ai = 0; ai < n_valid - 1; ai++) {
        const int *om_a = ominos + (size_t)valid_old[ai] * total;
        for (int bi = ai + 1; bi < n_valid; bi++) {
            const int *om_b = ominos + (size_t)valid_old[bi] * total;
            int overlap = 0;
            for (int v = 0; v < total; v++) {
                if (om_a[v] + om_b[v] > 1) { overlap = 1; break; }
            }
            if (overlap) continue;
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

    /* Pass 2: fill */
    memset(cp_count, 0, n_valid * sizeof(int));
    for (int ai = 0; ai < n_valid - 1; ai++) {
        const int *om_a = ominos + (size_t)valid_old[ai] * total;
        for (int bi = ai + 1; bi < n_valid; bi++) {
            const int *om_b = ominos + (size_t)valid_old[bi] * total;
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

    /* ---- Build filtered output ominos matrix (total x n_valid) ---- */
    SEXP ominos_out = PROTECT(allocMatrix(INTSXP, total, n_valid));
    int *out = INTEGER(ominos_out);
    vi = 0;
    for (int i = 0; i < n_ominos; i++) {
        if (!valid[i]) continue;
        memcpy(out + (size_t)vi * total,
               ominos + (size_t)i * total,
               total * sizeof(int));
        vi++;
    }

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
 * Shared enumeration state and recursive backtracking
 * ----------------------------------------------------------------------- */
typedef struct {
    const int *ominos;       /* total x n_ominos, col-major */
    const int *fd_ptr;       /* first_dict CSR ptr */
    const int *fd_data;      /* first_dict CSR data, 0-indexed */
    const char *compat_mat;  /* n_ominos x n_ominos boolean */
    int total;
    int n_ominos;
    int num_parts;
    int *plan;               /* plan[num_parts] */
    int *covered;            /* covered[total], 0/1 */
    int *assignment;         /* assignment[total], 1-indexed part */
    /* Output mode — exactly one of the following is non-NULL/non-zero: */
    int  count_only;         /* 1 = just count */
    int *out_direct;         /* fill pre-allocated matrix directly */
    FILE *out_file;          /* stream to binary file */
    /* State */
    int count;
} EnumState;

static void recurs_part(EnumState *s, int plan_len, int covered_count) {
    if (plan_len == s->num_parts) {
        if (covered_count == s->total) {
            if (s->out_direct) {
                memcpy(s->out_direct + (size_t)s->count * s->total,
                       s->assignment, s->total * sizeof(int));
            } else if (s->out_file) {
                if ((int)fwrite(s->assignment, sizeof(int), s->total,
                                s->out_file) != s->total) {
                    error("write error in C_stream_enumeration");
                }
            }
            s->count++;
        }
        return;
    }

    if (covered_count == s->total) return;

    int fz = 0;
    while (fz < s->total && s->covered[fz]) fz++;

    for (int k = s->fd_ptr[fz]; k < s->fd_ptr[fz + 1]; k++) {
        int q = s->fd_data[k];

        int ok = 1;
        for (int i = 0; i < plan_len; i++) {
            if (!s->compat_mat[(size_t)s->plan[i] * s->n_ominos + q]) {
                ok = 0;
                break;
            }
        }
        if (!ok) continue;

        s->plan[plan_len] = q;
        const int *om = s->ominos + (size_t)q * s->total;
        int newly_covered = 0;
        for (int v = 0; v < s->total; v++) {
            if (om[v]) {
                s->covered[v] = 1;
                s->assignment[v] = plan_len + 1;
                newly_covered++;
            }
        }

        recurs_part(s, plan_len + 1, covered_count + newly_covered);

        for (int v = 0; v < s->total; v++) {
            if (om[v]) {
                s->covered[v] = 0;
                s->assignment[v] = 0;
            }
        }
    }
}

/* Shared setup: build compat_mat and run the enumeration outer loop. */
static void run_core(
    const int *ominos, const int *fd_ptr, const int *fd_data,
    const int *cp_ptr, const int *cp_data,
    int total, int n_ominos, int num_parts,
    int count_only, int *out_direct, FILE *out_file,
    int *out_count
) {
    char *compat_mat = (char *)R_alloc((size_t)n_ominos * n_ominos, sizeof(char));
    memset(compat_mat, 0, (size_t)n_ominos * n_ominos * sizeof(char));
    for (int i = 0; i < n_ominos; i++) {
        for (int k = cp_ptr[i]; k < cp_ptr[i + 1]; k++) {
            int j = cp_data[k];
            compat_mat[(size_t)i * n_ominos + j] = 1;
        }
    }

    int *plan       = (int *)R_alloc(num_parts, sizeof(int));
    int *covered    = (int *)R_alloc(total, sizeof(int));
    int *assignment = (int *)R_alloc(total, sizeof(int));
    memset(covered,    0, total * sizeof(int));
    memset(assignment, 0, total * sizeof(int));

    EnumState s;
    s.ominos      = ominos;
    s.fd_ptr      = fd_ptr;
    s.fd_data     = fd_data;
    s.compat_mat  = compat_mat;
    s.total       = total;
    s.n_ominos    = n_ominos;
    s.num_parts   = num_parts;
    s.plan        = plan;
    s.covered     = covered;
    s.assignment  = assignment;
    s.count_only  = count_only;
    s.out_direct  = out_direct;
    s.out_file    = out_file;
    s.count       = 0;

    for (int k = fd_ptr[0]; k < fd_ptr[1]; k++) {
        int p = fd_data[k];
        s.plan[0] = p;
        const int *om = ominos + (size_t)p * total;
        int covered_count = 0;
        for (int v = 0; v < total; v++) {
            covered[v]    = om[v] ? 1 : 0;
            assignment[v] = om[v] ? 1 : 0;
            if (om[v]) covered_count++;
        }
        recurs_part(&s, 1, covered_count);
    }

    *out_count = s.count;
}

/* -----------------------------------------------------------------------
 * C_run_enumeration — count partitions only.
 *
 * Arguments: ominos_mat, fd_ptr, fd_data, cp_ptr, cp_data,
 *            total, n_ominos, num_parts, collect (ignored — kept for API compat)
 * Returns: ScalarInteger(count)
 * ----------------------------------------------------------------------- */
SEXP C_run_enumeration(
    SEXP ominos_mat, SEXP fd_ptr_sexp, SEXP fd_data_sexp,
    SEXP cp_ptr_sexp, SEXP cp_data_sexp,
    SEXP total_sexp, SEXP n_ominos_sexp, SEXP num_parts_sexp,
    SEXP collect_sexp  /* ignored */
) {
    int total     = INTEGER(total_sexp)[0];
    int n_ominos  = INTEGER(n_ominos_sexp)[0];
    int num_parts = INTEGER(num_parts_sexp)[0];
    int count;

    run_core(INTEGER(ominos_mat), INTEGER(fd_ptr_sexp), INTEGER(fd_data_sexp),
             INTEGER(cp_ptr_sexp), INTEGER(cp_data_sexp),
             total, n_ominos, num_parts,
             1, NULL, NULL, &count);

    return ScalarInteger(count);
}

/* -----------------------------------------------------------------------
 * C_fill_enumeration — fill a pre-allocated integer matrix.
 *
 * Arguments: ominos_mat, fd_ptr, fd_data, cp_ptr, cp_data,
 *            total, n_ominos, num_parts, out_mat
 * Returns: R_NilValue (modifies out_mat in place)
 * ----------------------------------------------------------------------- */
SEXP C_fill_enumeration(
    SEXP ominos_mat, SEXP fd_ptr_sexp, SEXP fd_data_sexp,
    SEXP cp_ptr_sexp, SEXP cp_data_sexp,
    SEXP total_sexp, SEXP n_ominos_sexp, SEXP num_parts_sexp,
    SEXP out_sexp
) {
    int total     = INTEGER(total_sexp)[0];
    int n_ominos  = INTEGER(n_ominos_sexp)[0];
    int num_parts = INTEGER(num_parts_sexp)[0];
    int count;

    run_core(INTEGER(ominos_mat), INTEGER(fd_ptr_sexp), INTEGER(fd_data_sexp),
             INTEGER(cp_ptr_sexp), INTEGER(cp_data_sexp),
             total, n_ominos, num_parts,
             0, INTEGER(out_sexp), NULL, &count);

    return R_NilValue;
}

/* -----------------------------------------------------------------------
 * C_stream_enumeration — write all partitions to a binary file.
 *
 * Each partition is written as `total` consecutive native-endian 32-bit ints.
 * Arguments: ominos_mat, fd_ptr, fd_data, cp_ptr, cp_data,
 *            total, n_ominos, num_parts, file_path
 * Returns: ScalarInteger(count)
 * ----------------------------------------------------------------------- */
SEXP C_stream_enumeration(
    SEXP ominos_mat, SEXP fd_ptr_sexp, SEXP fd_data_sexp,
    SEXP cp_ptr_sexp, SEXP cp_data_sexp,
    SEXP total_sexp, SEXP n_ominos_sexp, SEXP num_parts_sexp,
    SEXP file_path_sexp
) {
    int total     = INTEGER(total_sexp)[0];
    int n_ominos  = INTEGER(n_ominos_sexp)[0];
    int num_parts = INTEGER(num_parts_sexp)[0];
    const char *path = CHAR(STRING_ELT(file_path_sexp, 0));

    FILE *f = fopen(path, "wb");
    if (!f) error("cannot open file '%s' for writing", path);

    /* Write n_cells as a 4-byte header so the file is self-describing. */
    if (fwrite(&total, sizeof(int), 1, f) != 1) {
        fclose(f);
        error("write error in C_stream_enumeration");
    }

    int count;
    run_core(INTEGER(ominos_mat), INTEGER(fd_ptr_sexp), INTEGER(fd_data_sexp),
             INTEGER(cp_ptr_sexp), INTEGER(cp_data_sexp),
             total, n_ominos, num_parts,
             0, NULL, f, &count);

    fclose(f);
    return ScalarInteger(count);
}

/* -----------------------------------------------------------------------
 * Symbol registration
 * ----------------------------------------------------------------------- */
static const R_CallMethodDef call_methods[] = {
    {"C_build_conflicts",    (DL_FUNC)&C_build_conflicts,    6},
    {"C_run_enumeration",    (DL_FUNC)&C_run_enumeration,    9},
    {"C_fill_enumeration",   (DL_FUNC)&C_fill_enumeration,   9},
    {"C_stream_enumeration", (DL_FUNC)&C_stream_enumeration, 9},
    {NULL, NULL, 0}
};

void R_init_enum(DllInfo *dll) {
    R_registerRoutines(dll, NULL, call_methods, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
