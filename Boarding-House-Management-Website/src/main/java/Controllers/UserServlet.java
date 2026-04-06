package Controllers;

import DALs.UserDAO;
import Models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class UserServlet extends HttpServlet {

    private UserDAO userDAO;

    private static final int PAGE_SIZE = 10;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    // ===================== GET =====================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        switch (action) {

            case "list":
                listUsers(request, response);
                break;

            case "edit":
                showEdit(request, response);
                break;

            case "delete":
                deleteUser(request, response);
                break;

            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ===================== POST =====================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        switch (action) {

            case "update":
                updateUser(request, response);
                break;

            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ===================== LIST (Manage Profile) =====================

    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isAdminOrStaff(session)) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String search = request.getParameter("search");
        String roleFilter = request.getParameter("role");

        List<User> users = userDAO.getAllUsers();

        // Filter in memory (simple approach — no extra DAO method needed)
        if (search != null && !search.trim().isEmpty()) {
            String kw = search.trim().toLowerCase();
            users.removeIf(u ->
                !u.getUsername().toLowerCase().contains(kw)
                && (u.getFullName() == null || !u.getFullName().toLowerCase().contains(kw))
                && (u.getEmail() == null || !u.getEmail().toLowerCase().contains(kw))
            );
        }
        if (roleFilter != null && !roleFilter.trim().isEmpty()) {
            users.removeIf(u -> !roleFilter.equals(u.getRole()));
        }

        request.setAttribute("users",      users);
        request.setAttribute("search",      search);
        request.setAttribute("roleFilter",  roleFilter);

        // Pagination
        int totalItems = users.size();
        int totalPages = Math.max(1, (int) Math.ceil((double) totalItems / PAGE_SIZE));
        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try { page = Integer.parseInt(pageParam); } catch (NumberFormatException ignored) {}
        }
        page = Math.min(Math.max(page, 1), totalPages);
        int fromIndex = (page - 1) * PAGE_SIZE;
        int toIndex   = Math.min(fromIndex + PAGE_SIZE, totalItems);
        List<User> pageUsers = (fromIndex < totalItems) ? users.subList(fromIndex, toIndex) : java.util.Collections.emptyList();

        request.setAttribute("users",       pageUsers);
        request.setAttribute("totalItems",  totalItems);
        request.setAttribute("totalPages",  totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize",    PAGE_SIZE);

        request.getRequestDispatcher("/views/admin/users/users.jsp")
                .forward(request, response);
    }

    // ===================== SHOW EDIT FORM =====================

    private void showEdit(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isAdminOrStaff(session)) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/user?action=list");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            User user = userDAO.getUserById(id);

            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/user?action=list");
                return;
            }

            request.setAttribute("editUser", user);
            request.getRequestDispatcher("/views/admin/users/editUser.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/user?action=list");
        }
    }

    // ===================== UPDATE USER =====================

    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isAdminOrStaff(session)) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        try {
            User user = new User();
            user.setUserId(Integer.parseInt(request.getParameter("userId")));
            user.setUsername(request.getParameter("username"));
            user.setFullName(request.getParameter("fullName"));
            user.setEmail(request.getParameter("email"));
            String phoneVal = request.getParameter("phone");
            // Server-side phone validation
            if (phoneVal != null && !phoneVal.trim().isEmpty()
                    && !phoneVal.trim().matches("^(0|\\+84)[0-9]{9}$")) {
                session.setAttribute("adminError", "Số điện thoại không hợp lệ (VD: 0912345678)");
                response.sendRedirect(request.getContextPath() + "/user?action=edit&id=" + user.getUserId());
                return;
            }
            user.setPhone(phoneVal);
            user.setRole(request.getParameter("role"));
            user.setImage(request.getParameter("image") != null
                    ? request.getParameter("image") : "default.png");

            String newPassword    = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");

            // Server-side confirm password check
            if (newPassword != null && !newPassword.trim().isEmpty()) {
                if (confirmPassword == null || !newPassword.trim().equals(confirmPassword.trim())) {
                    session.setAttribute("adminError", "Mật khẩu xác nhận không khớp");
                    response.sendRedirect(request.getContextPath() + "/user?action=edit&id=" + user.getUserId());
                    return;
                }
            }
            user.setPassword(newPassword != null ? newPassword.trim() : "");

            boolean success = userDAO.updateUserById(user);

            if (success) {
                session.setAttribute("adminSuccess", "Cập nhật người dùng thành công!");
            } else {
                session.setAttribute("adminError", "Cập nhật thất bại, vui lòng thử lại");
            }

            response.sendRedirect(request.getContextPath() + "/user?action=list");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/user?action=list");
        }
    }

    // ===================== DELETE USER =====================

    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (!isAdminOrStaff(session)) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                userDAO.deleteSoft(id);
                session.setAttribute("adminSuccess", "Xóa người dùng thành công!");
            } catch (NumberFormatException ignored) {}
        }

        response.sendRedirect(request.getContextPath() + "/user?action=list");
    }

    // ===================== HELPER =====================

    private boolean isAdminOrStaff(HttpSession session) {
        if (session == null) return false;
        User u = (User) session.getAttribute("user");
        if (u == null) return false;
        return "admin".equalsIgnoreCase(u.getRole())
                || "staff".equalsIgnoreCase(u.getRole());
    }
}
