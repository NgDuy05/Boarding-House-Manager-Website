package Controllers;

import DALs.PriceDAO;
import Models.PriceCategory;
import Models.PriceHistory;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PriceServlet extends HttpServlet {

    private PriceDAO priceDAO;

    @Override
    public void init() {
        priceDAO = new PriceDAO();
    }

    // ================= GET =================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            action = "categories";
        }

        switch (action) {
            case "create":
                showCreateForm(request, response);
                break;

            case "edit":
                showEditForm(request, response);
                break;

            case "delete":
                deleteCategory(request, response);
                break;

            default:
                listCategories(request, response);
        }
    }

    // ================= POST =================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("create".equals(action)) {
            createCategory(request, response);
        } else if ("edit".equals(action)) {
            updateCategory(request, response);
        }
    }

    // ================= LIST =================
   private void listCategories(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    String type = request.getParameter("type");

    List<PriceCategory> categories;

    if (type != null && !type.isEmpty()) {
        categories = priceDAO.getCategoriesByType(type);
    } else {
        categories = priceDAO.getAllPriceCategories();
    }

    Map<Integer, BigDecimal> currentMap = new HashMap<>();
    Map<Integer, BigDecimal> futureMap = new HashMap<>();

    for (PriceCategory c : categories) {

        BigDecimal current = priceDAO.getCurrentPrice(c.getCategoryId());
        BigDecimal future = priceDAO.getFuturePrice(c.getCategoryId());

        currentMap.put(c.getCategoryId(),
                current != null ? current : BigDecimal.ZERO);

        futureMap.put(c.getCategoryId(),
                future != null ? future : BigDecimal.ZERO);
    }

    request.setAttribute("categories", categories);
    request.setAttribute("currentMap", currentMap);
    request.setAttribute("futureMap", futureMap);
    request.setAttribute("type", type);

    request.getRequestDispatcher("/views/admin/prices/priceCategories.jsp")
            .forward(request, response);
}
   // ================= SHOW CREATE =================
    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("today", LocalDate.now().toString());

        request.getRequestDispatcher("/views/admin/prices/createPriceCategory.jsp")
                .forward(request, response);
    }

    // ================= CREATE =================
    private void createCategory(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        try {
            PriceCategory cat = buildCategoryFromRequest(request);

            BigDecimal price = new BigDecimal(request.getParameter("priceAmount"));
            LocalDate date = LocalDate.parse(request.getParameter("effectiveFrom"));

            // ❌ validate
            if (!date.isAfter(LocalDate.now())) {
                response.sendRedirect("price?action=create&error=date");
                return;
            }

            int id = priceDAO.insertCategoryWithPrice(cat, price, date);

            if (id == -1) {
                response.sendRedirect("price?action=create&error=db");
                return;
            }

            response.sendRedirect("price?action=categories");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("price?action=create&error=exception");
        }
    }

    // ================= SHOW EDIT =================
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        PriceCategory category = priceDAO.getCategoryById(id);
        BigDecimal currentPrice = priceDAO.getCurrentPrice(id);
        List<PriceHistory> history = priceDAO.getPriceHistoryByCategory(id);

        request.setAttribute("category", category);
        request.setAttribute("currentPrice", currentPrice);
        request.setAttribute("history", history);
        request.setAttribute("today", LocalDate.now().toString());

        request.getRequestDispatcher("/views/admin/prices/editPriceCategory.jsp")
                .forward(request, response);
    }

    // ================= UPDATE =================
    private void updateCategory(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        try {
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));

            PriceCategory cat = buildCategoryFromRequest(request);
            cat.setCategoryId(categoryId);

            String priceStr = request.getParameter("priceAmount");
            String dateStr = request.getParameter("effectiveFrom");

            // ================= CASE 1: NO PRICE CHANGE =================
            if (isEmpty(priceStr) || isEmpty(dateStr)) {

                priceDAO.updateCategoryOnly(cat);
                } // ================= CASE 2: UPDATE PRICE =================
            else {

                BigDecimal price = new BigDecimal(priceStr);
                LocalDate date = LocalDate.parse(dateStr);

                if (!date.isAfter(LocalDate.now())) {
                    response.sendRedirect("price?action=edit&id=" + categoryId + "&error=date");
                    return;
                }

                priceDAO.updateCategoryWithPrice(cat, price, date);
            }

            response.sendRedirect("price?action=categories");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("price?action=edit&error=exception");
        }
    }

    // ================= DELETE =================
    private void deleteCategory(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        priceDAO.softDeleteCategory(id);

        response.sendRedirect("price?action=categories");
    }

    // ================= HELPER =================
    private PriceCategory buildCategoryFromRequest(HttpServletRequest request) {

        PriceCategory cat = new PriceCategory();

        cat.setCategoryCode(request.getParameter("categoryCode").trim());
        cat.setCategoryType(request.getParameter("categoryType").trim());
        cat.setUnit(request.getParameter("unit"));

        return cat;
    }

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }
}