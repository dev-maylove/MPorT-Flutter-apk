# Flutter deep audit fixes (MODULE-FIX v2)

## Bugs fixed

1. **Module list empty / single weird card**  
   Laravel paginator returns `{ data: { data: [...], current_page } }`.  
   UI now unwraps nested `data.data` lists.

2. **Reports/settings object display**  
   Nested stats maps render as readable key-value cards, not one opaque card.

3. **Back button after `context.go` from drawer**  
   `context.pop()` failed with no stack. Now falls back to role home
   (`/admin`, `/tech`, `/app`).

4. **401 on module load**  
   Logs out and redirects to `/login`.

5. **ApiResponse.message**  
   Handles non-string `message` / `error` fields from Laravel.

6. **Tech map filter query**  
   Uses `query: {'filter': ...}` instead of embedding `?filter=` in path.

7. **Tech jobs data source**  
   Tries `/api/v1/modules/tech-jobs` first, falls back to `/api/tickets`.  
   Unwraps paginated lists.

8. **Logout**  
   Navigates to `/login` after logout from drawer.

9. **Indonesian module titles**  
   reports → Laporan, notifications → Notifikasi, etc.

## Pair with backend

Use `MPorT.v2.0.1-hardened-FLUTTER-READY.zip` so `/api/v1/modules/*` exists.
