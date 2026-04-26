package Controllers;

import DALs.FacilityDAO;
import DALs.PriceDAO;
import DALs.RoomCategoryDAO;
import DALs.UtilityDAO;
import Models.Facility;
import Models.PriceCategory;
import Models.PriceHistory;
import Models.RoomCategory;
import Models.Utility;
import Models.UtilityPrice;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PriceServlet extends HttpServlet {

    private PriceDAO priceDAO;
    private RoomCategoryDAO roomCategoryDAO;
    private FacilityDAO facilityDAO;
    private UtilityDAO utilityDAO;

    @Override
    public void init() {
        priceDAO = new PriceDAO();
        roomCategoryDAO = new RoomCategoryDAO();
        facilityDAO = new FacilityDAO();
        utilityDAO = new UtilityDAO();
    }

    // ================= GET =================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "categories";

        switch (action) {
            case "create":            showCreateForm(request, response);       break;
            case "edit":              showEditForm(request, response);          break;
            case "delete":            deleteCategory(request, response);        break;
            case "editRoomCategory":  showEditRoomCategory(request, response);  break;
            case "editFacilityPrice": showEditFacilityPrice(request, response); break;
            case "editUtilityPrice":  showEditUtilityPrice(request, response);  break;
            default:                  listCategories(request, response);
        }
    }

    // ================= POST =================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        switch (action == null ? "" : action) {
            case "create":            createCategory(request, response);    break;
            case "edit":              updateCategory(request, response);    break;
            case "saveRoomCategory":  saveRoomCategory(request, response);  break;
            case "saveFacilityPrice": saveFacilityPrice(request, response); break;
            case "saveUtilityPrice":  saveUtilityPrice(request, response);  break;
            default:                  response.sendRedirect("price?action=categories");
        }
    }

    // ================= LIST =================
    private void listCategories(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String type = request.getParameter("type");

        // --- Service/Rent via price_history ---
        List<PriceCategory> categories = (type != null && !type.isEmpty())
                ? priceDAO.getCategoriesByType(type)
                : priceDAO.getAllPriceCategories();

        Map<Integer, BigDecimal> currentMap = new HashMap<>();
        Map<Integer, BigDecimal> futureMap  = new HashMap<>();
        for (PriceCategory c : categories) {
            currentMap.put(c.getCategoryId(), nvl(priceDAO.getCurrentPrice(c.getCategoryId())));
            futureMap .put(c.getCategoryId(), nvl(priceDAO.getFuturePrice(c.getCategoryId())));
        }

        // --- Room categories ---
        List<RoomCategory> roomCategories = roomCategoryDAO.getAllCategoriesWithCount();

        // --- Facilities ---
        List<Facility> facilities = facilityDAO.getAllFacilities();

        // --- Utilities current + future ---
        List<Utility> utilities = utilityDAO.getAllUtilities();
        Map<Integer, BigDecimal> utilityCurrentMap = new HashMap<>();
        Map<Integer, BigDecimal> utilityFutureMap  = new HashMap<>();
        for (Utility u : utilities) {
            if (!u.isIsDeleted()) {
                UtilityPrice cur = utilityDAO.getCurrentPrice(u.getUtilityId());
                UtilityPrice fut = utilityDAO.getFuturePrice(u.getUtilityId());
                utilityCurrentMap.put(u.getUtilityId(), cur != null ? cur.getPrice() : null);
                utilityFutureMap .put(u.getUtilityId(), fut != null ? fut.getPrice() : null);
            }
        }

        request.setAttribute("categories",       categories);
        request.setAttribute("currentMap",        currentMap);
        request.setAttribute("futureMap",         futureMap);
        request.setAttribute("roomCategories",    roomCategories);
        request.setAttribute("facilities",        facilities);
        request.setAttribute("utilities",         utilities);
        request.setAttribute("utilityCurrentMap", utilityCurrentMap);
        request.setAttribute("utilityFutureMap",  utilityFutureMap);
        request.setAttribute("type",              type);

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
            BigDecimal price  = new BigDecimal(request.getParameter("priceAmount"));
            LocalDate date    = LocalDate.parse(request.getParameter("effectiveFrom"));
            if (!date.isAfter(LocalDate.now())) {
                response.sendRedirect("price?action=create&error=date"); return;
            }
            int id = priceDAO.insertCategoryWithPrice(cat, price, date);
            if (id == -1) { response.sendRedirect("price?action=create&error=db"); return; }
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
        PriceCategory category     = priceDAO.getCategoryById(id);
        BigDecimal currentPrice    = priceDAO.getCurrentPrice(id);
        List<PriceHistory> history = priceDAO.getPriceHistoryByCategory(id);
        request.setAttribute("category",     category);
        request.setAttribute("currentPrice", currentPrice);
        request.setAttribute("history",      history);
        request.setAttribute("today",        LocalDate.now().toString());
        request.getRequestDispatcher("/views/admin/prices/editPriceCategory.jsp")
                .forward(request, response);
    }

    // ================= UPDATE =================
    private void updateCategory(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int categoryId    = Integer.parseInt(request.getParameter("categoryId"));
            PriceCategory cat = buildCategoryFromRequest(request);
            cat.setCategoryId(categoryId);
            String priceStr = request.getParameter("priceAmount");
            String dateStr  = request.getParameter("effectiveFrom");
            if (isEmpty(priceStr) || isEmpty(dateStr)) {
                priceDAO.updateCategoryOnly(cat);
            } else {
                BigDecimal price = new BigDecimal(priceStr);
                LocalDate date   = LocalDate.parse(dateStr);
                if (!date.isAfter(LocalDate.now())) {
                    response.sendRedirect("price?action=edit&id=" + categoryId + "&error=date"); return;
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

    // ============================================================ ROOM CATEGORY
    private void showEditRoomCategory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        RoomCategory rc = roomCategoryDAO.getCategoryById(id);
        if (rc == null) { response.sendRedirect("price?action=categories&error=notfound"); return; }
        request.setAttribute("roomCategory", rc);
        request.getRequestDispatcher("/views/admin/prices/editRoomCategory.jsp").forward(request, response);
    }

    private void saveRoomCategory(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            RoomCategory rc = new RoomCategory();
            rc.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
            rc.setCategoryName(request.getParameter("categoryName"));
            rc.setDescription(request.getParameter("description"));
            rc.setBasePrice(new BigDecimal(request.getParameter("basePrice")));
            rc.setPricePerDay(new BigDecimal(request.getParameter("pricePerDay")));
            roomCategoryDAO.updateCategory(rc);
            response.sendRedirect("price?action=categories&type=rent");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("price?action=categories&error=savefail");
        }
    }

    // ============================================================ FACILITY PRICE
    private void showEditFacilityPrice(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Facility f = facilityDAO.getFacilityById(id);
        if (f == null) { response.sendRedirect("price?action=categories&error=notfound"); return; }
        request.setAttribute("facility", f);
        request.getRequestDispatcher("/views/admin/prices/editFacilityPrice.jsp").forward(request, response);
    }

    private void saveFacilityPrice(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id           = Integer.parseInt(request.getParameter("facilityId"));
            BigDecimal price = new BigDecimal(request.getParameter("monthlyPrice"));
            facilityDAO.updateMonthlyPrice(id, price);
            response.sendRedirect("price?action=categories&type=facility");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("price?action=categories&error=savefail");
        }
    }

    // ============================================================ UTILITY PRICE
    private void showEditUtilityPrice(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Utility u = utilityDAO.getUtilityById(id);
        if (u == null) { response.sendRedirect("price?action=categories&error=notfound"); return; }
        UtilityPrice currentPrice = utilityDAO.getCurrentPrice(id);
        request.setAttribute("utility",      u);
        request.setAttribute("currentPrice", currentPrice);
        request.setAttribute("today",        LocalDate.now().toString());
        request.getRequestDispatcher("/views/admin/prices/editUtilityPrice.jsp").forward(request, response);
    }

    private void saveUtilityPrice(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int utilityId    = Integer.parseInt(request.getParameter("utilityId"));
            BigDecimal price = new BigDecimal(request.getParameter("price"));
            LocalDate effDate = LocalDate.parse(request.getParameter("effectiveFrom"));
            UtilityPrice up = new UtilityPrice();
            up.setUtilityId(utilityId);
            up.setPrice(price);
            up.setEffectiveFrom(Date.valueOf(effDate));
            utilityDAO.insertPrice(up);
            response.sendRedirect("price?action=categories&type=utility");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("price?action=categories&error=savefail");
        }
    }

    // ================= HELPERS =================
    private PriceCategory buildCategoryFromRequest(HttpServletRequest request) {
        PriceCategory cat = new PriceCategory();
        cat.setCategoryCode(request.getParameter("categoryCode").trim());
        cat.setCategoryType(request.getParameter("categoryType").trim());
        cat.setUnit(request.getParameter("unit"));
        return cat;
    }

    private boolean isEmpty(String s) { return s == null || s.trim().isEmpty(); }
    private BigDecimal nvl(BigDecimal v) { return v != null ? v : BigDecimal.ZERO; }
}