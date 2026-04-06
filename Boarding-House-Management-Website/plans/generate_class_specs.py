"""
Generate Class Specifications tables for all use cases in the SDS document.
Insert tables right after 'b. Class Specifications' paragraphs (where no table follows).
Fix: reassign all w:id attributes after deep-copy to avoid duplicate IDs that corrupt .docx.
"""
import copy
import itertools
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from docx.shared import Pt, RGBColor
from lxml import etree

INPUT_PATH  = r'C:\Users\FPTSHOP\Downloads\Template3_SDS Document (1).docx'
OUTPUT_PATH = r'C:\Users\FPTSHOP\Downloads\Template3_SDS Document (1) - Updated.docx'

# Global counter to generate unique w:id values across all inserted elements
_id_counter = itertools.count(10000)

def make_unique_id():
    return str(next(_id_counter))

def make_unique_para_id():
    """Generate a unique 8-char hex string for w14:paraId."""
    n = next(_id_counter)
    return format(n, '08X')

# Namespace for w14 (Word 2010 extensions)
W14_NS = 'http://schemas.microsoft.com/office/word/2010/wordml'

def fix_ids(element):
    """
    Recursively replace all duplicate-prone ID attributes with unique values:
      - w:id        (bookmarks, revisions, etc.)
      - w14:paraId  (paragraph unique ID — Word REQUIRES global uniqueness)
      - w14:textId  (text run unique ID)
    """
    W_ID     = qn('w:id')
    W14_PARA = f'{{{W14_NS}}}paraId'
    W14_TEXT = f'{{{W14_NS}}}textId'

    for el in element.iter():
        if W_ID in el.attrib:
            el.set(W_ID, make_unique_id())
        if W14_PARA in el.attrib:
            el.set(W14_PARA, make_unique_para_id())
        if W14_TEXT in el.attrib:
            el.set(W14_TEXT, make_unique_para_id())
    return element

# ─────────────────────────────────────────────────────────────────────────────
# DATA: Class Specifications per use case
# Format: list of {uc_heading, servlet_class, servlet_rows, dao_class, dao_rows}
# Each row: (no, method, description)
# ─────────────────────────────────────────────────────────────────────────────
UC_SPECS = [
    # ── UC-2: View room categories ────────────────────────────────────────────
    {
        "heading_contains": "View room categories",
        "servlet_class": "RoomServlet",
        "servlet_rows": [
            ("01", "doGet(request, response)",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to home.jsp with room category list.\n"
             "Processing: Reads action='categories'. Calls RoomCategoryDAO.getAllCategoriesWithCount() to retrieve all categories with room counts. Sets attribute 'categories' and forwards to home.jsp."),
        ],
        "dao_class": "RoomCategoryDAO",
        "dao_rows": [
            ("01", "getAllCategoriesWithCount()",
             "Inputs: None.\n"
             "Outputs: List<RoomCategory> — all categories with associated room count.\n"
             "Processing: Executes SELECT query joining room_category and room tables, groups by category to count rooms per category, returns mapped list."),
            ("02", "getAllCategories()",
             "Inputs: None.\n"
             "Outputs: List<RoomCategory>.\n"
             "Processing: Executes SELECT * FROM room_category and maps each row to a RoomCategory object."),
        ],
    },

    # ── UC-2 (3): View room list ──────────────────────────────────────────────
    {
        "heading_contains": "View room list",
        "heading_not_contains": "owner",
        "heading_index": 0,
        "servlet_class": "RoomServlet",
        "servlet_rows": [
            ("01", "doGet(request, response)",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to rooms.jsp with paginated room list.\n"
             "Processing: Reads action='list'. Calls RoomDAO.getAllRooms(). Applies pagination. Sets attributes 'rooms', 'currentPage', 'totalPages' and forwards to rooms.jsp."),
        ],
        "dao_class": "RoomDAO",
        "dao_rows": [
            ("01", "getAllRooms()",
             "Inputs: None.\n"
             "Outputs: List<Room> — all rooms.\n"
             "Processing: Executes SELECT with JOIN on room_category, maps each ResultSet row to a Room model object."),
        ],
    },

    # ── UC-4: Filter rooms ───────────────────────────────────────────────────
    {
        "heading_contains": "Filter rooms",
        "servlet_class": "RoomServlet",
        "servlet_rows": [
            ("01", "doGet(request, response)",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to rooms.jsp with filtered room list.\n"
             "Processing: Reads action='list', plus query params: category, status, keyword. Calls appropriate RoomDAO methods based on filters provided. Sets 'rooms' attribute and forwards."),
        ],
        "dao_class": "RoomDAO",
        "dao_rows": [
            ("01", "getByStatus(status)",
             "Inputs: String status.\n"
             "Outputs: List<Room>.\n"
             "Processing: Executes SELECT * FROM room WHERE status = ? and maps results."),
            ("02", "getRoomsByCategoryId(categoryId)",
             "Inputs: int categoryId.\n"
             "Outputs: List<Room>.\n"
             "Processing: Executes SELECT * FROM room WHERE category_id = ? and maps results."),
            ("03", "getRoomsByCategoryAndStatus(categoryId, status)",
             "Inputs: int categoryId, String status.\n"
             "Outputs: List<Room>.\n"
             "Processing: Executes SELECT with WHERE category_id = ? AND status = ? and maps results."),
            ("04", "searchByNumber(keyword)",
             "Inputs: String keyword.\n"
             "Outputs: List<Room>.\n"
             "Processing: Executes SELECT with WHERE room_number LIKE ? and maps results."),
        ],
    },

    # ── UC-5: View room detail ────────────────────────────────────────────────
    {
        "heading_contains": "View room detail",
        "servlet_class": "RoomServlet",
        "servlet_rows": [
            ("01", "doGet(request, response)",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to room-detail.jsp with room details, amenities, and facilities.\n"
             "Processing: Reads action='detail', param 'id'. Calls RoomDAO.getRoomById(id), AmenityDAO.getAmenitiesByRoomId(id), FacilityDAO.getFacilitiesByRoom(id). Sets attributes 'room', 'amenities', 'facilities' and forwards."),
        ],
        "dao_class": "RoomDAO",
        "dao_rows": [
            ("01", "getRoomById(id)",
             "Inputs: int id.\n"
             "Outputs: Room object or null.\n"
             "Processing: Executes SELECT with JOIN room_category WHERE room_id = ?. Maps ResultSet to Room model."),
        ],
    },

    # ── UC-6: View room amenities ─────────────────────────────────────────────
    {
        "heading_contains": "View room amenities",
        "servlet_class": "RoomServlet",
        "servlet_rows": [
            ("01", "doGet(request, response)",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to room-detail.jsp with amenity list for the room.\n"
             "Processing: Reads action='detail', param 'id'. Calls AmenityDAO.getAmenitiesByRoomId(id). Sets attribute 'amenities' and forwards to room detail view."),
        ],
        "dao_class": "AmenityDAO",
        "dao_rows": [
            ("01", "getAmenitiesByRoomId(roomId)",
             "Inputs: int roomId.\n"
             "Outputs: List<Amenity>.\n"
             "Processing: Executes SELECT joining amenity and room_amenity WHERE room_id = ? AND is_deleted = 0. Maps each row to Amenity model."),
        ],
    },

    # ── UC-7: Logout ──────────────────────────────────────────────────────────
    {
        "heading_contains": "Logout",
        "servlet_class": "AuthServlet",
        "servlet_rows": [
            ("01", "doGet(request, response)",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to /home.\n"
             "Processing: Reads action='logout'. Calls logout() helper. Retrieves current session via getSession(false), calls session.invalidate() to clear all session attributes. Redirects to home page."),
        ],
        "dao_class": "UserDAO",
        "dao_rows": [
            ("01", "getUserById(id)",
             "Inputs: int id.\n"
             "Outputs: User object or null.\n"
             "Processing: Executes SELECT * FROM [user] WHERE user_id = ? AND is_deleted = 0. Maps row to User model. (Used for session validation checks.)"),
        ],
    },

    # ── UC-8: Reset password ──────────────────────────────────────────────────
    {
        "heading_contains": "Reset pas",
        "servlet_class": "AuthServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='forgetPassword'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to forgetPassword.jsp (phase 1).\n"
             "Processing: Sets request attribute 'phase'=1 and forwards to the forget-password form."),
            ("02", "doPost(request, response) — action='verifyReset'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to forgetPassword.jsp (phase 2 — OTP entry).\n"
             "Processing: Reads 'email' param. Calls UserDAO.findByEmail(). Generates OTP via OtpStore.generate(). Sends OTP email via EmailService.sendOtpEmail(). Stores resetEmail in session. Forwards to phase 2."),
            ("03", "doPost(request, response) — action='verifyOtp'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to forgetPassword.jsp (phase 3 — new password).\n"
             "Processing: Retrieves resetEmail from session. Validates OTP via OtpStore.verify(). On success, removes OTP, sets session attribute 'otpVerified'=true, forwards to phase 3."),
            ("04", "doPost(request, response) — action='doResetPassword'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to login page.\n"
             "Processing: Validates session (resetEmail, otpVerified). Reads newPassword/confirmPassword. Calls UserDAO.resetPassword(). Clears session attributes. Redirects to login with success message."),
        ],
        "dao_class": "UserDAO",
        "dao_rows": [
            ("01", "findByEmail(email)",
             "Inputs: String email.\n"
             "Outputs: User object or null.\n"
             "Processing: Executes SELECT * FROM [user] WHERE email = ? AND is_deleted = 0. Returns mapped User or null."),
            ("02", "resetPassword(userId, newPassword)",
             "Inputs: int userId, String newPassword.\n"
             "Outputs: boolean — true if update succeeded.\n"
             "Processing: Hashes newPassword with MD5. Executes UPDATE [user] SET password = ? WHERE user_id = ?. Returns affected rows > 0."),
        ],
    },

    # ── UC-9.1: View profile ──────────────────────────────────────────────────
    {
        "heading_contains": "View profile",
        "servlet_class": "CustomerServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='profile'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to customer/profile.jsp with user data.\n"
             "Processing: Validates session; retrieves User from session. Sets attribute 'user'. Calls showProfile(). Forwards to profile view."),
        ],
        "dao_class": "UserDAO",
        "dao_rows": [
            ("01", "getUserById(id)",
             "Inputs: int id.\n"
             "Outputs: User object or null.\n"
             "Processing: Executes SELECT * FROM [user] WHERE user_id = ? AND is_deleted = 0. Maps row to User model."),
        ],
    },

    # ── UC-9.2: Update profile ────────────────────────────────────────────────
    {
        "heading_contains": "Update profile",
        "servlet_class": "CustomerServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='editProfile'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to customer/editProfile.jsp.\n"
             "Processing: Validates session. Sets user attribute from session. Forwards to edit profile form."),
            ("02", "doPost(request, response) — action='updateProfile'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to profile page with success/error message.\n"
             "Processing: Reads fullName, email, phone from request. Validates inputs. Builds updated User object. Calls UserDAO.updateUserById(user). Updates session user attribute on success. Redirects back to profile."),
        ],
        "dao_class": "UserDAO",
        "dao_rows": [
            ("01", "updateUserById(user)",
             "Inputs: User object.\n"
             "Outputs: boolean — true if update succeeded.\n"
             "Processing: Executes UPDATE [user] SET full_name=?, email=?, phone=?, image=? WHERE user_id=?. Returns affected rows > 0."),
        ],
    },

    # ── UC-9.3: Change password ───────────────────────────────────────────────
    {
        "heading_contains": "Change password",
        "servlet_class": "AuthServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='changePassword'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to customer/changePassword.jsp.\n"
             "Processing: Validates session. Forwards to the change-password form."),
            ("02", "doPost(request, response) — action='changePassword'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to changePassword.jsp with success or error message.\n"
             "Processing: Reads oldPassword, newPassword, confirmPassword. Validates non-empty and match. Calls UserDAO.changePassword(). Sets success or error attribute. Forwards back to form."),
        ],
        "dao_class": "UserDAO",
        "dao_rows": [
            ("01", "changePassword(userId, oldPassword, newPassword)",
             "Inputs: int userId, String oldPassword, String newPassword.\n"
             "Outputs: boolean — true if password updated.\n"
             "Processing: Retrieves stored hashed password by userId. Compares MD5(oldPassword) with stored hash. If match, updates password to MD5(newPassword). Returns true on success."),
        ],
    },

    # ── UC-10.1: View rental contract ─────────────────────────────────────────
    {
        "heading_contains": "View rental contract",
        "servlet_class": "ContractServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='myContracts'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to customer/myContracts.jsp with contract list.\n"
             "Processing: Validates session. Reads userId from session. Calls ContractDAO.getContractsByUserId(userId). Sets 'contracts' attribute. Forwards to view."),
        ],
        "dao_class": "ContractDAO",
        "dao_rows": [
            ("01", "getContractsByUserId(userId)",
             "Inputs: int userId.\n"
             "Outputs: List<Contract>.\n"
             "Processing: Executes SELECT joining contract and contract_tenant tables WHERE user_id = ?. Maps each row to a Contract model."),
            ("02", "getActiveContractByUserId(userId)",
             "Inputs: int userId.\n"
             "Outputs: Contract or null.\n"
             "Processing: Executes SELECT with JOIN WHERE user_id = ? AND status = 'active'. Returns first match or null."),
        ],
    },

    # ── UC-10.2: View rented room ─────────────────────────────────────────────
    {
        "heading_contains": "View rented room",
        "servlet_class": "ContractServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='myContractDetail'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to customer/contractDetail.jsp with room and contract info.\n"
             "Processing: Validates session. Reads contractId from param. Calls ContractDAO.getDetailById(contractId). Loads room info via RoomDAO.getRoomById(). Sets attributes and forwards."),
        ],
        "dao_class": "ContractDAO",
        "dao_rows": [
            ("01", "getDetailById(id)",
             "Inputs: int id.\n"
             "Outputs: Contract with room details.\n"
             "Processing: Executes SELECT joining contract, room, user tables WHERE contract_id = ?. Maps full details to Contract model."),
        ],
    },

    # ── UC-11: Login ──────────────────────────────────────────────────────────
    {
        "heading_contains": "Login",
        "heading_not_contains": "Owner",
        "servlet_class": "AuthServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='login'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to login.jsp or redirect to dashboard if already logged in.\n"
             "Processing: Checks session for existing user. If found, redirects to /dashboard. Otherwise forwards to login.jsp."),
            ("02", "doPost(request, response) — action='login'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to /dashboard on success, or forward to login.jsp with error.\n"
             "Processing: Reads username and password. Calls UserDAO.login(username, password). On success, creates session and stores User object. On failure, sets error attribute and forwards back to form."),
        ],
        "dao_class": "UserDAO",
        "dao_rows": [
            ("01", "login(username, password)",
             "Inputs: String username, String password.\n"
             "Outputs: User object or null.\n"
             "Processing: Executes SELECT WHERE userName = ? AND is_deleted = 0. Compares MD5(password) with stored hash. Returns mapped User if match, null otherwise."),
        ],
    },

    # ── UC-12.1: View bill list ───────────────────────────────────────────────
    {
        "heading_contains": "View bill list",
        "heading_not_contains": "owner",
        "servlet_class": "BillServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='myBills'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to customer/myBills.jsp with bill list.\n"
             "Processing: Validates session. Reads userId from session. Calls BillDAO.getBillByTenant(userId). Sets 'bills' attribute. Forwards to customer bill list view."),
        ],
        "dao_class": "BillDAO",
        "dao_rows": [
            ("01", "getBillByTenant(userId)",
             "Inputs: int userId.\n"
             "Outputs: List<Bill>.\n"
             "Processing: Executes SELECT joining bill, contract, contract_tenant WHERE user_id = ?. Maps each row to Bill model with room and period info."),
        ],
    },

    # ── UC-12.2: View payment history ─────────────────────────────────────────
    {
        "heading_contains": "View payment history",
        "servlet_class": "BillServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='myBills'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to customer/myBills.jsp filtered to paid bills.\n"
             "Processing: Validates session. Reads userId. Calls BillDAO.getBillByTenant(userId). Filters list for status='paid'. Sets 'paidBills' attribute. Forwards to view."),
        ],
        "dao_class": "BillDAO",
        "dao_rows": [
            ("01", "getBillByTenant(userId)",
             "Inputs: int userId.\n"
             "Outputs: List<Bill>.\n"
             "Processing: Executes SELECT joining bill and contract tables WHERE userId matches tenant. Returns all bills including paid ones for payment history display."),
        ],
    },

    # ── UC-12.3: Pay bill ─────────────────────────────────────────────────────
    {
        "heading_contains": "Pay bill",
        "servlet_class": "BillServlet",
        "servlet_rows": [
            ("01", "doPost(request, response) — action='updateStatus'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to bill list with success/error message.\n"
             "Processing: Reads billId and status='paid'. Validates ownership. Calls BillDAO.updateStatus(billId, 'paid'). Redirects to myBills with success confirmation."),
        ],
        "dao_class": "BillDAO",
        "dao_rows": [
            ("01", "updateStatus(billId, status)",
             "Inputs: int billId, String status.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE bill SET status = ? WHERE bill_id = ?. Marks the bill as paid."),
            ("02", "getBillById(id)",
             "Inputs: int id.\n"
             "Outputs: Bill object or null.\n"
             "Processing: Executes SELECT * FROM bill WHERE bill_id = ?. Maps row to Bill model including associated items and contract info."),
        ],
    },

    # ── UC-13: View notification list ─────────────────────────────────────────
    {
        "heading_contains": "View notification list",
        "servlet_class": "NotificationServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='list'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to customer/notifications.jsp with notification list.\n"
             "Processing: Validates session. Reads userId from session. Calls NotificationDAO.getNotificationsForUser(userId). Sets 'notifications' and 'unreadCount' attributes. Forwards to view."),
        ],
        "dao_class": "NotificationDAO",
        "dao_rows": [
            ("01", "getNotificationsForUser(userId)",
             "Inputs: int userId.\n"
             "Outputs: List<Notification>.\n"
             "Processing: Executes SELECT WHERE target_user_id = ? OR target_user_id IS NULL ORDER BY created_at DESC. Maps each row to Notification model."),
            ("02", "countForUser(userId)",
             "Inputs: int userId.\n"
             "Outputs: int — count of unread notifications.\n"
             "Processing: Executes SELECT COUNT(*) WHERE target matches userId and is_read = 0."),
        ],
    },

    # ── UC-14.1: Select service type ──────────────────────────────────────────
    {
        "heading_contains": "Select service type",
        "servlet_class": "ServiceServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='publicList'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to customer/services.jsp with available service list.\n"
             "Processing: Calls ServiceDAO.getAllServices() to get active services. Sets 'services' attribute. Forwards to public service list view."),
            ("02", "doPost(request, response) — action='request'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to service list with success/error.\n"
             "Processing: Validates session. Reads serviceId, quantity, usageDate. Calls ServiceDAO.getActiveContractIdByUserId(). Calls ServiceDAO.requestService(contractId, serviceId, quantity, date). Redirects with message."),
        ],
        "dao_class": "ServiceDAO",
        "dao_rows": [
            ("01", "getAllServices()",
             "Inputs: None.\n"
             "Outputs: List<Service> — active services visible to customers.\n"
             "Processing: Executes SELECT * FROM service WHERE is_deleted = 0. Maps each row to Service model."),
            ("02", "requestService(contractId, serviceId, quantity, usageDate)",
             "Inputs: int contractId, int serviceId, BigDecimal quantity, LocalDate usageDate.\n"
             "Outputs: boolean — true if request created.\n"
             "Processing: Inserts a new ServiceUsage record with status='pending'. Returns true if INSERT succeeded."),
            ("03", "getActiveContractIdByUserId(userId)",
             "Inputs: int userId.\n"
             "Outputs: int — active contract ID or 0.\n"
             "Processing: Queries contract_tenant JOIN contract WHERE user_id = ? AND status='active'. Returns contract_id."),
        ],
    },

    # ── UC-15: View service history ───────────────────────────────────────────
    {
        "heading_contains": "View service history",
        "servlet_class": "ServiceServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='myHistory'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to customer/serviceHistory.jsp with usage history.\n"
             "Processing: Validates session. Reads userId from session. Calls ServiceDAO.getUsageByUserId(userId). Sets 'usages' attribute. Forwards to history view."),
        ],
        "dao_class": "ServiceDAO",
        "dao_rows": [
            ("01", "getUsageByUserId(userId)",
             "Inputs: int userId.\n"
             "Outputs: List<ServiceUsage>.\n"
             "Processing: Executes SELECT joining service_usage, service, contract_tenant WHERE user_id = ?. Maps rows to ServiceUsage with service name and cost details."),
        ],
    },

    # ── UC-16.1: View room list (owner) ───────────────────────────────────────
    {
        "heading_contains": "View room list (owner)",
        "servlet_class": "RoomServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='list'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/rooms.jsp with all rooms and status counts.\n"
             "Processing: Validates admin/owner session. Calls RoomDAO.getAllRooms(). Calls RoomDAO.getCountByStatus() for summary stats. Sets attributes and forwards to owner room list view."),
        ],
        "dao_class": "RoomDAO",
        "dao_rows": [
            ("01", "getAllRooms()",
             "Inputs: None.\n"
             "Outputs: List<Room>.\n"
             "Processing: Executes SELECT * FROM room JOIN room_category. Maps all rows to Room model objects."),
            ("02", "getCountByStatus()",
             "Inputs: None.\n"
             "Outputs: Map<String, Integer> — count per status.\n"
             "Processing: Executes SELECT status, COUNT(*) FROM room GROUP BY status. Returns map with keys: available, rented, maintenance."),
        ],
    },

    # ── UC-16.2: Update room ──────────────────────────────────────────────────
    {
        "heading_contains": "Update room",
        "servlet_class": "RoomServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='editForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/editRoom.jsp with room data pre-filled.\n"
             "Processing: Reads 'id' param. Calls RoomDAO.getRoomById(id). Calls RoomCategoryDAO.getAllCategories() for dropdown. Sets attributes and forwards."),
            ("02", "doPost(request, response) — action='update'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to room list with success message.\n"
             "Processing: Reads roomId, roomNumber, categoryId, price, status, description. Builds Room object. Calls RoomDAO.updateRoom(room). Redirects to list."),
        ],
        "dao_class": "RoomDAO",
        "dao_rows": [
            ("01", "updateRoom(room)",
             "Inputs: Room object.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE room SET room_number=?, category_id=?, price=?, status=?, description=? WHERE room_id=?."),
            ("02", "getRoomById(id)",
             "Inputs: int id.\n"
             "Outputs: Room object.\n"
             "Processing: Executes SELECT with JOIN WHERE room_id = ?. Maps row to Room model."),
        ],
    },

    # ── UC-16.3: Delete room ──────────────────────────────────────────────────
    {
        "heading_contains": "Delete room",
        "servlet_class": "RoomServlet",
        "servlet_rows": [
            ("01", "doPost(request, response) — action='delete'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to owner room list with success/error.\n"
             "Processing: Reads 'id' param. Validates admin session. Calls RoomDAO.deleteRoom(id) to permanently remove the room record. Redirects to room list."),
        ],
        "dao_class": "RoomDAO",
        "dao_rows": [
            ("01", "deleteRoom(id)",
             "Inputs: int id.\n"
             "Outputs: void.\n"
             "Processing: Executes DELETE FROM room WHERE room_id = ?. Removes the room and cascades to related facility records."),
        ],
    },

    # ── UC-16.4: Add room ─────────────────────────────────────────────────────
    {
        "heading_contains": "Add room",
        "servlet_class": "RoomServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='createForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/createRoom.jsp with category dropdown.\n"
             "Processing: Calls RoomCategoryDAO.getAllCategories(). Sets 'categories' attribute. Forwards to create room form."),
            ("02", "doPost(request, response) — action='insert'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to room list with success message.\n"
             "Processing: Reads roomNumber, categoryId, price, status, description. Builds Room object. Calls RoomDAO.insertRoom(room). Redirects to room list."),
        ],
        "dao_class": "RoomDAO",
        "dao_rows": [
            ("01", "insertRoom(room)",
             "Inputs: Room object.\n"
             "Outputs: void.\n"
             "Processing: Executes INSERT INTO room (room_number, category_id, price, status, description, created_at). Sets generated key on the Room object."),
        ],
    },

    # ── UC-16.5: Manage room amenities ────────────────────────────────────────
    {
        "heading_contains": "Manage room amenities",
        "servlet_class": "AmenityServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='list'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/amenities.jsp with amenity list.\n"
             "Processing: Calls AmenityDAO.getAllAmenities(). Sets 'amenities' attribute. Forwards to amenity management view."),
            ("02", "doPost(request, response) — action='assignToRoom'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to room detail with success message.\n"
             "Processing: Reads roomId, amenityId[]. Calls AmenityDAO.removeAllAmenitiesFromRoom(roomId) then calls AmenityDAO.assignAmenityToRoom() for each selected amenity. Redirects."),
        ],
        "dao_class": "AmenityDAO",
        "dao_rows": [
            ("01", "getAllAmenities()",
             "Inputs: None.\n"
             "Outputs: List<Amenity>.\n"
             "Processing: Executes SELECT * FROM amenity WHERE is_deleted = 0 ORDER BY amenity_name. Maps rows to Amenity model."),
            ("02", "assignAmenityToRoom(roomId, amenityId)",
             "Inputs: int roomId, int amenityId.\n"
             "Outputs: void.\n"
             "Processing: Executes INSERT INTO room_amenity (room_id, amenity_id) if not already present."),
            ("03", "removeAllAmenitiesFromRoom(roomId)",
             "Inputs: int roomId.\n"
             "Outputs: void.\n"
             "Processing: Executes DELETE FROM room_amenity WHERE room_id = ? to clear all existing amenity assignments before re-assigning."),
        ],
    },

    # ── UC-17.1: View customer list ───────────────────────────────────────────
    {
        "heading_contains": "View customer list",
        "servlet_class": "ManageCustomerServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='list'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/customers.jsp with customer list.\n"
             "Processing: Validates admin/owner session. Reads optional 'search' and 'status' params. Calls UserDAO.getAllCustomers(search, statusFilter). Sets 'customers' attribute. Forwards to view."),
        ],
        "dao_class": "UserDAO",
        "dao_rows": [
            ("01", "getAllCustomers(search, statusFilter)",
             "Inputs: String search (nullable), String statusFilter (nullable).\n"
             "Outputs: List<User>.\n"
             "Processing: Builds dynamic SELECT with optional WHERE clauses for full_name/username LIKE ? and is_deleted filter. Returns list of customer-role users."),
        ],
    },

    # ── UC-17.2: View room list (customer management context) ─────────────────
    {
        "heading_contains": "17.2 View room list",
        "servlet_class": "RoomServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='list'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/rooms.jsp with available rooms for assignment.\n"
             "Processing: Validates admin session. Calls RoomDAO.getAvailableRooms(). Sets 'rooms' attribute. Used in customer management context to assign rooms to new contracts."),
        ],
        "dao_class": "RoomDAO",
        "dao_rows": [
            ("01", "getAvailableRooms()",
             "Inputs: None.\n"
             "Outputs: List<Room>.\n"
             "Processing: Executes SELECT * FROM room WHERE status = 'available'. Maps rows to Room model."),
        ],
    },

    # ── UC-17.2: Add customer information ─────────────────────────────────────
    {
        "heading_contains": "Add customer information",
        "servlet_class": "ManageCustomerServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='createForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/createCustomer.jsp.\n"
             "Processing: Validates admin/owner session. Forwards to the create customer form."),
            ("02", "doPost(request, response) — action='insert'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to customer list with success/error message.\n"
             "Processing: Reads fullName, username, email, phone, password. Validates uniqueness via UserDAO.existsByUsername(). Builds User object with role='customer'. Calls UserDAO.insertCustomer(user). Redirects to list."),
        ],
        "dao_class": "UserDAO",
        "dao_rows": [
            ("01", "insertCustomer(user)",
             "Inputs: User object.\n"
             "Outputs: boolean — true if insert succeeded.\n"
             "Processing: Hashes password with MD5. Executes INSERT INTO [user] with all user fields and role='customer'. Returns affected rows > 0."),
            ("02", "existsByUsername(username)",
             "Inputs: String username.\n"
             "Outputs: boolean.\n"
             "Processing: Executes SELECT COUNT(*) FROM [user] WHERE userName = ?. Returns count > 0."),
        ],
    },

    # ── UC-17.3: Update customer information ──────────────────────────────────
    {
        "heading_contains": "Updatecustomer information",
        "servlet_class": "ManageCustomerServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='editForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/editCustomer.jsp with customer data.\n"
             "Processing: Reads 'id' param. Calls UserDAO.getUserById(id). Sets 'customer' attribute. Forwards to edit form."),
            ("02", "doPost(request, response) — action='update'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to customer list with success message.\n"
             "Processing: Reads fullName, email, phone from request. Builds User object. Calls UserDAO.updateUserById(user). Redirects to list."),
        ],
        "dao_class": "UserDAO",
        "dao_rows": [
            ("01", "updateUserById(user)",
             "Inputs: User object.\n"
             "Outputs: boolean.\n"
             "Processing: Executes UPDATE [user] SET full_name=?, email=?, phone=? WHERE user_id=?. Returns affected rows > 0."),
            ("02", "getUserById(id)",
             "Inputs: int id.\n"
             "Outputs: User object or null.\n"
             "Processing: Executes SELECT * FROM [user] WHERE user_id = ? AND is_deleted = 0."),
        ],
    },

    # ── UC-17.4: Delete customer ──────────────────────────────────────────────
    {
        "heading_contains": "Delete customer",
        "servlet_class": "ManageCustomerServlet",
        "servlet_rows": [
            ("01", "doPost(request, response) — action='hide'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to customer list with success message.\n"
             "Processing: Reads 'id' param. Validates admin session. Calls UserDAO.deleteSoft(id) to set is_deleted=1. Redirects to customer list."),
        ],
        "dao_class": "UserDAO",
        "dao_rows": [
            ("01", "deleteSoft(id)",
             "Inputs: int id.\n"
             "Outputs: boolean.\n"
             "Processing: Executes UPDATE [user] SET is_deleted = 1 WHERE user_id = ?. Returns affected rows > 0. Does not physically delete the record."),
        ],
    },

    # ── UC-18.1: View contract detail ─────────────────────────────────────────
    {
        "heading_contains": "View contract detail",
        "servlet_class": "ContractServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='detail'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/contractDetail.jsp with full contract info.\n"
             "Processing: Reads 'id' param. Calls ContractDAO.getDetailById(id) for contract and room info. Calls ContractDAO.getTenantsWithInfo(id) for tenant list. Calls DepositDAO.getBalance(). Sets all attributes and forwards."),
        ],
        "dao_class": "ContractDAO",
        "dao_rows": [
            ("01", "getDetailById(id)",
             "Inputs: int id.\n"
             "Outputs: Contract with joined room and user details.\n"
             "Processing: Executes SELECT with multiple JOINs (contract, room, user) WHERE contract_id = ?. Maps full contract details."),
            ("02", "getTenantsWithInfo(contractId)",
             "Inputs: int contractId.\n"
             "Outputs: List<ContractUser>.\n"
             "Processing: Executes SELECT joining contract_tenant and [user] WHERE contract_id = ?. Returns all tenants with role and joined_at info."),
        ],
    },

    # ── UC-18.2: Create contract ──────────────────────────────────────────────
    {
        "heading_contains": "Create contract",
        "servlet_class": "ContractServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='createForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/createContract.jsp with available rooms and customers.\n"
             "Processing: Calls RoomDAO.getAvailableRooms(). Calls UserDAO.getCustomersWithoutActiveContract(). Sets attributes. Forwards to create form."),
            ("02", "doPost(request, response) — action='insert'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to contract list with success/error message.\n"
             "Processing: Reads roomId, primaryUserId, startDate, endDate, depositAmount, monthlyRent. Builds Contract object. Calls ContractDAO.insertWithContractTenant(). Updates RoomDAO.updateStatus() to 'rented'. Redirects to list."),
        ],
        "dao_class": "ContractDAO",
        "dao_rows": [
            ("01", "insertWithContractTenant(contract, primaryTenant)",
             "Inputs: Contract object, ContractTenant object.\n"
             "Outputs: int — generated contract ID.\n"
             "Processing: Executes INSERT INTO contract, then INSERT INTO contract_tenant with the primary tenant. Returns generated contract_id."),
        ],
    },

    # ── UC-18.3: Update rental contract ──────────────────────────────────────
    {
        "heading_contains": "Update rental contract",
        "servlet_class": "ContractServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='editForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/editContract.jsp with contract data.\n"
             "Processing: Reads 'id' param. Calls ContractDAO.getById(id). Sets 'contract' attribute. Forwards to edit form."),
            ("02", "doPost(request, response) — action='update'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to contract detail with success message.\n"
             "Processing: Reads updated fields (endDate, monthlyRent, status, etc.). Builds Contract. Calls ContractDAO.update(contract). Redirects to detail page."),
        ],
        "dao_class": "ContractDAO",
        "dao_rows": [
            ("01", "update(contract)",
             "Inputs: Contract object.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE contract SET end_date=?, monthly_rent=?, status=?, notes=? WHERE contract_id=?."),
            ("02", "getById(id)",
             "Inputs: int id.\n"
             "Outputs: Contract object.\n"
             "Processing: Executes SELECT * FROM contract WHERE contract_id = ?. Maps to Contract model."),
        ],
    },

    # ── UC-18.4: Terminate rental contract ────────────────────────────────────
    {
        "heading_contains": "Terminate rental contract",
        "servlet_class": "ContractServlet",
        "servlet_rows": [
            ("01", "doPost(request, response) — action='terminate'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to contract list with success message.\n"
             "Processing: Reads contractId and roomId. Calls ContractDAO.terminate(contractId, roomId) which sets contract status='terminated' and room status='available'. Redirects to list."),
        ],
        "dao_class": "ContractDAO",
        "dao_rows": [
            ("01", "terminate(contractId, roomId)",
             "Inputs: int contractId, int roomId.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE contract SET status='terminated', end_date=NOW() WHERE contract_id=?. Then UPDATE room SET status='available' WHERE room_id=?."),
        ],
    },

    # ── UC-18.5: Deposit ──────────────────────────────────────────────────────
    {
        "heading_contains": "Deposit",
        "servlet_class": "DepositServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='form'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/depositForm.jsp with contract and balance info.\n"
             "Processing: Reads contractId. Calls DepositDAO.getByContractId(contractId) and DepositDAO.getBalance(contractId). Sets attributes. Forwards to deposit form."),
            ("02", "doPost(request, response) — action='record'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to deposit list or contract detail.\n"
             "Processing: Reads contractId, amount, type (deposit/refund), notes. Builds DepositTransaction object. Calls DepositDAO.insert(transaction). Redirects."),
        ],
        "dao_class": "DepositDAO",
        "dao_rows": [
            ("01", "insert(depositTransaction)",
             "Inputs: DepositTransaction object.\n"
             "Outputs: int — generated transaction ID.\n"
             "Processing: Executes INSERT INTO deposit_transaction (contract_id, amount, type, transaction_date, notes). Returns generated ID."),
            ("02", "getBalance(contractId)",
             "Inputs: int contractId.\n"
             "Outputs: BigDecimal — net deposit balance.\n"
             "Processing: Executes SELECT SUM(CASE WHEN type='deposit' THEN amount ELSE -amount END) WHERE contract_id = ?."),
            ("03", "getByContractId(contractId)",
             "Inputs: int contractId.\n"
             "Outputs: List<DepositTransaction>.\n"
             "Processing: Executes SELECT * FROM deposit_transaction WHERE contract_id = ? ORDER BY transaction_date DESC."),
        ],
    },

    # ── UC-18.6: Manage co-tenant ─────────────────────────────────────────────
    {
        "heading_contains": "Manage co-tenant",
        "servlet_class": "ContractServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='addTenantForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/addTenant.jsp.\n"
             "Processing: Reads contractId. Calls UserDAO.getCustomersWithoutActiveContract(). Sets eligible customers. Forwards to add tenant form."),
            ("02", "doPost(request, response) — action='addTenant'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to contract detail.\n"
             "Processing: Reads contractId, userId, role, joinedAt. Calls ContractDAO.addTenant(). Redirects to contract detail page."),
            ("03", "doPost(request, response) — action='removeTenant'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to contract detail.\n"
             "Processing: Reads contractId, userId. Calls ContractDAO.removeTenant(contractId, userId). Redirects to contract detail."),
        ],
        "dao_class": "ContractDAO",
        "dao_rows": [
            ("01", "addTenant(contractId, userId, role, joinedAt)",
             "Inputs: int contractId, int userId, String role, LocalDate joinedAt.\n"
             "Outputs: boolean.\n"
             "Processing: Executes INSERT INTO contract_tenant (contract_id, user_id, role, joined_at). Returns affected rows > 0."),
            ("02", "removeTenant(contractId, userId)",
             "Inputs: int contractId, int userId.\n"
             "Outputs: boolean.\n"
             "Processing: Executes DELETE FROM contract_tenant WHERE contract_id = ? AND user_id = ?. Returns affected rows > 0."),
        ],
    },

    # ── UC-19: Login (Owner) ──────────────────────────────────────────────────
    {
        "heading_contains": "Login (Owner)",
        "servlet_class": "AuthServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='login'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to login.jsp or redirect to dashboard.\n"
             "Processing: Same as customer login. Checks existing session. If found, redirects to /dashboard. Otherwise forwards to login.jsp."),
            ("02", "doPost(request, response) — action='login'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to /dashboard (owner dashboard) on success.\n"
             "Processing: Calls UserDAO.login(username, password). On success, stores User in session. Role-based routing on dashboard redirects owner to owner panel."),
        ],
        "dao_class": "UserDAO",
        "dao_rows": [
            ("01", "login(username, password)",
             "Inputs: String username, String password.\n"
             "Outputs: User object or null.\n"
             "Processing: Executes SELECT WHERE userName = ? AND is_deleted = 0. Compares MD5(password) with stored hash. Returned User's role is checked (owner/admin) for access control."),
        ],
    },

    # ── UC-20.1: Record utility usage ─────────────────────────────────────────
    {
        "heading_contains": "Record utility usage",
        "servlet_class": "UtilityServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='addUsageForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/addUsage.jsp with utility and room lists.\n"
             "Processing: Calls UtilityDAO.getAllUtilities(). Calls RoomDAO.getAllRooms(). Sets attributes. Forwards to usage entry form."),
            ("02", "doPost(request, response) — action='insertUsage'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to utility detail with success message.\n"
             "Processing: Reads utilityId, roomId, previousReading, currentReading, recordDate. Builds UtilityUsage. Calls UtilityDAO.insertUsage(). Redirects."),
        ],
        "dao_class": "UtilityDAO",
        "dao_rows": [
            ("01", "insertUsage(utilityUsage)",
             "Inputs: UtilityUsage object.\n"
             "Outputs: void.\n"
             "Processing: Executes INSERT INTO utility_usage (utility_id, room_id, previous_reading, current_reading, record_date). Calculates consumption = current - previous."),
            ("02", "getAllUsages()",
             "Inputs: None.\n"
             "Outputs: List<UtilityUsage>.\n"
             "Processing: Executes SELECT joining utility_usage, utility, room. Returns all usage records with utility and room names."),
        ],
    },

    # ── UC-20.2: Set utility price ────────────────────────────────────────────
    {
        "heading_contains": "Set utility price",
        "servlet_class": "UtilityServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='addPriceForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/addUtilityPrice.jsp.\n"
             "Processing: Reads utilityId. Calls UtilityDAO.getUtilityById(utilityId) and getPricesByUtilityId(). Sets attributes. Forwards to price form."),
            ("02", "doPost(request, response) — action='insertPrice'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to utility detail page.\n"
             "Processing: Reads utilityId, unitPrice, effectiveDate. Builds UtilityPrice. Calls UtilityDAO.insertPrice(). Redirects to utility detail."),
        ],
        "dao_class": "UtilityDAO",
        "dao_rows": [
            ("01", "insertPrice(utilityPrice)",
             "Inputs: UtilityPrice object.\n"
             "Outputs: void.\n"
             "Processing: Executes INSERT INTO utility_price (utility_id, unit_price, effective_date). New price becomes effective from the given date."),
            ("02", "getCurrentPrice(utilityId)",
             "Inputs: int utilityId.\n"
             "Outputs: UtilityPrice — most recent price.\n"
             "Processing: Executes SELECT * FROM utility_price WHERE utility_id = ? ORDER BY effective_date DESC LIMIT 1."),
        ],
    },

    # ── UC-20.3: View utility detail ──────────────────────────────────────────
    {
        "heading_contains": "View utility detail",
        "servlet_class": "UtilityServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='detail'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/utilityDetail.jsp with utility, prices, and usages.\n"
             "Processing: Reads 'id' param. Calls UtilityDAO.getUtilityById(id), getPricesByUtilityId(id), getUsagesByUtilityId(id). Sets all attributes. Forwards to detail view."),
        ],
        "dao_class": "UtilityDAO",
        "dao_rows": [
            ("01", "getUtilityById(id)",
             "Inputs: int id.\n"
             "Outputs: Utility object or null.\n"
             "Processing: Executes SELECT * FROM utility WHERE utility_id = ? AND is_deleted = 0. Maps row to Utility model."),
            ("02", "getPricesByUtilityId(utilityId)",
             "Inputs: int utilityId.\n"
             "Outputs: List<UtilityPrice>.\n"
             "Processing: Executes SELECT * FROM utility_price WHERE utility_id = ? ORDER BY effective_date DESC."),
            ("03", "getUsagesByUtilityId(utilityId)",
             "Inputs: int utilityId.\n"
             "Outputs: List<UtilityUsage>.\n"
             "Processing: Executes SELECT * FROM utility_usage WHERE utility_id = ? ORDER BY record_date DESC."),
        ],
    },

    # ── UC-21.1: Add facility ─────────────────────────────────────────────────
    {
        "heading_contains": "Add facility",
        "servlet_class": "FacilityServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='createForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/createFacility.jsp.\n"
             "Processing: Validates admin session. Forwards to create facility form."),
            ("02", "doPost(request, response) — action='insert'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to facility list with success message.\n"
             "Processing: Reads facilityName, description, roomId (optional). Builds Facility object. Calls FacilityDAO.insertFacility(facility). Calls FacilityDAO.upsertRoomFacility() if roomId provided. Redirects."),
        ],
        "dao_class": "FacilityDAO",
        "dao_rows": [
            ("01", "insertFacility(facility)",
             "Inputs: Facility object.\n"
             "Outputs: void.\n"
             "Processing: Executes INSERT INTO facility (facility_name, description, created_at)."),
            ("02", "upsertRoomFacility(roomId, facilityId, quantity)",
             "Inputs: int roomId, int facilityId, int quantity.\n"
             "Outputs: boolean.\n"
             "Processing: Checks if room_facility record exists. If yes, updates quantity. If no, inserts new record."),
        ],
    },

    # ── UC-21.2: Update facility ──────────────────────────────────────────────
    {
        "heading_contains": "Update facility",
        "servlet_class": "FacilityServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='editForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/editFacility.jsp with facility data.\n"
             "Processing: Reads 'id' param. Calls FacilityDAO.getFacilityById(id). Sets 'facility' attribute. Forwards to edit form."),
            ("02", "doPost(request, response) — action='update'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to facility list with success message.\n"
             "Processing: Reads facilityId, facilityName, description. Builds Facility. Calls FacilityDAO.updateFacility(facility). Redirects to list."),
        ],
        "dao_class": "FacilityDAO",
        "dao_rows": [
            ("01", "updateFacility(facility)",
             "Inputs: Facility object.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE facility SET facility_name=?, description=? WHERE facility_id=?."),
            ("02", "getFacilityById(id)",
             "Inputs: int id.\n"
             "Outputs: Facility object or null.\n"
             "Processing: Executes SELECT * FROM facility WHERE facility_id = ?. Maps row to Facility model."),
        ],
    },

    # ── UC-21.3: Remove facility ──────────────────────────────────────────────
    {
        "heading_contains": "Remove facility",
        "servlet_class": "FacilityServlet",
        "servlet_rows": [
            ("01", "doPost(request, response) — action='delete'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to facility list with success message.\n"
             "Processing: Reads 'id' param. Validates admin session. Calls FacilityDAO.deleteFacility(id). Redirects to facility list."),
        ],
        "dao_class": "FacilityDAO",
        "dao_rows": [
            ("01", "deleteFacility(id)",
             "Inputs: int id.\n"
             "Outputs: void.\n"
             "Processing: Executes DELETE FROM facility WHERE facility_id = ?. Cascades to room_facility records via DB foreign key."),
        ],
    },

    # ── UC-21.4: View facility detail ─────────────────────────────────────────
    {
        "heading_contains": "View facility detail",
        "servlet_class": "FacilityServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='detail'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/facilityDetail.jsp.\n"
             "Processing: Reads 'id' param. Calls FacilityDAO.getFacilityById(id). Sets 'facility' attribute. Calls FacilityDAO.facilitiesByRoom() to get rooms that have this facility. Forwards to detail view."),
        ],
        "dao_class": "FacilityDAO",
        "dao_rows": [
            ("01", "getFacilityById(id)",
             "Inputs: int id.\n"
             "Outputs: Facility object.\n"
             "Processing: Executes SELECT * FROM facility WHERE facility_id = ?. Maps result to Facility model."),
            ("02", "getFacilitiesByRoom(roomId)",
             "Inputs: int roomId.\n"
             "Outputs: List<Facility>.\n"
             "Processing: Executes SELECT joining facility and room_facility WHERE room_id = ?. Returns facilities assigned to that room."),
        ],
    },

    # ── UC-22.1: Add amenity ──────────────────────────────────────────────────
    {
        "heading_contains": "Add amenity",
        "servlet_class": "AmenityServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='createForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/createAmenity.jsp.\n"
             "Processing: Validates admin session. Forwards to create amenity form."),
            ("02", "doPost(request, response) — action='insert'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to amenity list with success message.\n"
             "Processing: Reads amenityName, description. Builds Amenity object. Calls AmenityDAO.insertAmenity(amenity). Redirects to list."),
        ],
        "dao_class": "AmenityDAO",
        "dao_rows": [
            ("01", "insertAmenity(amenity)",
             "Inputs: Amenity object.\n"
             "Outputs: int — generated amenity ID.\n"
             "Processing: Executes INSERT INTO amenity (amenity_name, description, is_deleted). Returns generated key."),
        ],
    },

    # ── UC-22.2: Update amenity ───────────────────────────────────────────────
    {
        "heading_contains": "Update amenity",
        "servlet_class": "AmenityServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='editForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/editAmenity.jsp with amenity data.\n"
             "Processing: Reads 'id' param. Calls AmenityDAO.getAmenityById(id). Sets 'amenity' attribute. Forwards to edit form."),
            ("02", "doPost(request, response) — action='update'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to amenity list with success message.\n"
             "Processing: Reads amenityId, amenityName, description. Builds Amenity. Calls AmenityDAO.updateAmenity(amenity). Redirects to list."),
        ],
        "dao_class": "AmenityDAO",
        "dao_rows": [
            ("01", "updateAmenity(amenity)",
             "Inputs: Amenity object.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE amenity SET amenity_name=?, description=? WHERE amenity_id=?."),
            ("02", "getAmenityById(id)",
             "Inputs: int id.\n"
             "Outputs: Amenity object or null.\n"
             "Processing: Executes SELECT * FROM amenity WHERE amenity_id = ?. Maps row to Amenity model."),
        ],
    },

    # ── UC-22.3: Remove amenity ───────────────────────────────────────────────
    {
        "heading_contains": "Remove amenity",
        "servlet_class": "AmenityServlet",
        "servlet_rows": [
            ("01", "doPost(request, response) — action='delete'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to amenity list.\n"
             "Processing: Reads 'id' param. Calls AmenityDAO.deleteAmenity(id) which sets is_deleted=1 (soft delete). Redirects to amenity list."),
        ],
        "dao_class": "AmenityDAO",
        "dao_rows": [
            ("01", "deleteAmenity(id)",
             "Inputs: int id.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE amenity SET is_deleted = 1 WHERE amenity_id = ?. Soft delete to preserve references."),
        ],
    },

    # ── UC-22.4: Restore amenity ──────────────────────────────────────────────
    {
        "heading_contains": "Restore amenity",
        "servlet_class": "AmenityServlet",
        "servlet_rows": [
            ("01", "doPost(request, response) — action='restore'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to amenity list with success message.\n"
             "Processing: Reads 'id' param. Calls AmenityDAO.restoreAmenity(id) which sets is_deleted=0. Redirects to amenity list."),
        ],
        "dao_class": "AmenityDAO",
        "dao_rows": [
            ("01", "restoreAmenity(id)",
             "Inputs: int id.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE amenity SET is_deleted = 0 WHERE amenity_id = ?. Re-activates previously soft-deleted amenity."),
        ],
    },

    # ── UC-23.1: Create bill ──────────────────────────────────────────────────
    {
        "heading_contains": "Create bill",
        "servlet_class": "BillServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='createForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/createBill.jsp with contract list and bill items.\n"
             "Processing: Validates admin session. Calls ContractDAO.getAllWithDetails(). Calls BillDAO.getBillsWithRoomInfo(). Sets attributes. Forwards to create bill form."),
            ("02", "doPost(request, response) — action='createBill'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to bill list with success message.\n"
             "Processing: Reads contractId, period (year-month), item descriptions, amounts. Builds Bill with BillItems. Calls BillDAO.insertBillWithItems(bill, items). Redirects to bill list."),
        ],
        "dao_class": "BillDAO",
        "dao_rows": [
            ("01", "insertBillWithItems(bill, items)",
             "Inputs: Bill object, List<BillItem>.\n"
             "Outputs: int — generated bill ID.\n"
             "Processing: Inserts Bill record. For each BillItem, inserts into bill_item table with foreign key to bill. Calculates and stores total_amount. Returns bill_id."),
            ("02", "billExists(contractId, period)",
             "Inputs: int contractId, LocalDate period.\n"
             "Outputs: boolean.\n"
             "Processing: Executes SELECT COUNT(*) WHERE contract_id = ? AND period = ?. Returns count > 0 to prevent duplicate bills."),
        ],
    },

    # ── UC-23.2: View bill list (owner) ───────────────────────────────────────
    {
        "heading_contains": "23.2 View bill list",
        "servlet_class": "BillServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='ownerList'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/bills.jsp with all bills.\n"
             "Processing: Validates admin session. Calls BillDAO.getBillsWithRoomInfo(). Applies optional period/status filter. Sets 'bills' attribute. Forwards to owner bill list view."),
        ],
        "dao_class": "BillDAO",
        "dao_rows": [
            ("01", "getBillsWithRoomInfo()",
             "Inputs: None.\n"
             "Outputs: List<Bill> with room and contract info.\n"
             "Processing: Executes SELECT joining bill, contract, room tables. Maps all bills with room number and tenant info for owner display."),
        ],
    },

    # ── UC-23.3: Check bill payment status ────────────────────────────────────
    {
        "heading_contains": "Check bill payment status",
        "servlet_class": "BillServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='status'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/billStatus.jsp with unpaid bills.\n"
             "Processing: Validates admin session. Calls BillDAO.getUnpaidBills(). Sets 'unpaidBills' attribute. Forwards to bill status overview page."),
            ("02", "doPost(request, response) — action='updateStatus'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to bill status page.\n"
             "Processing: Reads billId, status. Calls BillDAO.updateStatus(billId, status). Redirects back to status page."),
        ],
        "dao_class": "BillDAO",
        "dao_rows": [
            ("01", "getUnpaidBills()",
             "Inputs: None.\n"
             "Outputs: List<Bill>.\n"
             "Processing: Executes SELECT * FROM bill WHERE status = 'unpaid' with room and contract JOIN. Returns all outstanding bills."),
            ("02", "updateStatus(billId, status)",
             "Inputs: int billId, String status.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE bill SET status = ? WHERE bill_id = ?."),
        ],
    },

    # ── UC-24.1: View service request list ────────────────────────────────────
    {
        "heading_contains": "View service request list",
        "servlet_class": "ServiceServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='manageRequests'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/serviceRequests.jsp with request list.\n"
             "Processing: Validates admin session. Reads optional 'status' filter. Calls ServiceDAO.getAllRequestsWithDetails(statusFilter). Sets 'requests' attribute. Forwards to request list view."),
        ],
        "dao_class": "ServiceDAO",
        "dao_rows": [
            ("01", "getAllRequestsWithDetails(statusFilter)",
             "Inputs: String statusFilter (nullable).\n"
             "Outputs: List<ServiceUsage>.\n"
             "Processing: Executes SELECT joining service_usage, service, contract, [user] with optional WHERE status = ?. Returns requests with service name and tenant info."),
            ("02", "countPendingRequests()",
             "Inputs: None.\n"
             "Outputs: int.\n"
             "Processing: Executes SELECT COUNT(*) FROM service_usage WHERE status = 'pending'. Used for dashboard badge."),
        ],
    },

    # ── UC-24.2: Update service request status ────────────────────────────────
    {
        "heading_contains": "Update service request status",
        "servlet_class": "ServiceServlet",
        "servlet_rows": [
            ("01", "doPost(request, response) — action='updateRequestStatus'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to service request list.\n"
             "Processing: Reads usageId, status. Validates admin session. Calls ServiceDAO.updateRequestStatus(usageId, status). Redirects back to request list."),
        ],
        "dao_class": "ServiceDAO",
        "dao_rows": [
            ("01", "updateRequestStatus(usageId, status)",
             "Inputs: int usageId, String status.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE service_usage SET status = ? WHERE usage_id = ?."),
        ],
    },

    # ── UC-24.3: Approve service request ─────────────────────────────────────
    {
        "heading_contains": "Approve service request",
        "servlet_class": "ServiceServlet",
        "servlet_rows": [
            ("01", "doPost(request, response) — action='approve'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to service request list with success message.\n"
             "Processing: Reads usageId. Validates admin session. Calls ServiceDAO.approveRequest(usageId) which sets status='approved'. Redirects to request list."),
        ],
        "dao_class": "ServiceDAO",
        "dao_rows": [
            ("01", "approveRequest(usageId)",
             "Inputs: int usageId.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE service_usage SET status = 'approved', approved_at = NOW() WHERE usage_id = ?."),
        ],
    },

    # ── UC-24.4: Reject service request ──────────────────────────────────────
    {
        "heading_contains": "Reject service request",
        "servlet_class": "ServiceServlet",
        "servlet_rows": [
            ("01", "doPost(request, response) — action='reject'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to service request list with success message.\n"
             "Processing: Reads usageId. Calls ServiceDAO.rejectRequest(usageId) which sets status='rejected'. Redirects to request list."),
        ],
        "dao_class": "ServiceDAO",
        "dao_rows": [
            ("01", "rejectRequest(usageId)",
             "Inputs: int usageId.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE service_usage SET status = 'rejected', rejected_at = NOW() WHERE usage_id = ?."),
        ],
    },

    # ── UC-24.5: Mark service as billed ──────────────────────────────────────
    {
        "heading_contains": "Marked service as billed",
        "servlet_class": "ServiceServlet",
        "servlet_rows": [
            ("01", "doPost(request, response) — action='markBilled'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to service list with success message.\n"
             "Processing: Reads contractId. Calls ServiceDAO.markUsageBilled(contractId) to update all approved usage records for that contract to is_billed=1. Redirects."),
        ],
        "dao_class": "ServiceDAO",
        "dao_rows": [
            ("01", "markUsageBilled(contractId)",
             "Inputs: int contractId.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE service_usage SET is_billed = 1 WHERE contract_id = ? AND status = 'approved' AND is_billed = 0."),
        ],
    },

    # ── UC-25: View activity logs ─────────────────────────────────────────────
    {
        "heading_contains": "View activity logs",
        "servlet_class": "ActivityLogServlet",
        "servlet_rows": [
            ("01", "doGet(request, response)",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/activityLogs.jsp with log list.\n"
             "Processing: Validates admin/staff session. Reads optional 'userId' and 'type' filter params. Calls ActivityLogDAO.getLogs(userId, typeFilter, ...). Sets 'logs' attribute. Forwards to log view."),
        ],
        "dao_class": "ActivityLogDAO",
        "dao_rows": [
            ("01", "getLogs(userId, typeFilter, ...)",
             "Inputs: int userId (0 = all), String typeFilter (nullable).\n"
             "Outputs: List<ActivityLog>.\n"
             "Processing: Builds dynamic SELECT with optional WHERE user_id = ? AND activity_type = ? clauses. Orders by created_at DESC. Maps rows to ActivityLog model."),
        ],
    },

    # ── UC-26: View facilities ────────────────────────────────────────────────
    {
        "heading_contains": "26. View facilities",
        "servlet_class": "FacilityServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='list'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/facilities.jsp with facility list.\n"
             "Processing: Validates session. Calls FacilityDAO.getAllFacilities(). Sets 'facilities' attribute. Forwards to facilities list view."),
        ],
        "dao_class": "FacilityDAO",
        "dao_rows": [
            ("01", "getAllFacilities()",
             "Inputs: None.\n"
             "Outputs: List<Facility>.\n"
             "Processing: Executes SELECT * FROM facility ORDER BY facility_name. Maps each row to Facility model object."),
        ],
    },

    # ── UC-27: Sign rental contract ───────────────────────────────────────────
    {
        "heading_contains": "Sign rental contract",
        "servlet_class": "ContractServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='signForm'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to customer/signContract.jsp with contract details.\n"
             "Processing: Validates customer session. Reads contractId param. Calls ContractDAO.getDetailById(contractId). Validates that contract belongs to current user. Sets 'contract' attribute. Forwards to sign form."),
            ("02", "doPost(request, response) — action='sign'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to customer contract page with success message.\n"
             "Processing: Reads contractId. Calls ContractDAO.customerSignContract(contractId, userId) to update signature status. Redirects to myContracts."),
        ],
        "dao_class": "ContractDAO",
        "dao_rows": [
            ("01", "getDetailById(id)",
             "Inputs: int id.\n"
             "Outputs: Contract with full details.\n"
             "Processing: Executes SELECT with multiple JOINs WHERE contract_id = ?. Returns contract with room and primary tenant info for display."),
            ("02", "update(contract)",
             "Inputs: Contract object with signed_at timestamp set.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE contract SET signed_at = NOW(), status = 'active' WHERE contract_id = ?."),
        ],
    },

    # ── UC-28: View notification detail ──────────────────────────────────────
    {
        "heading_contains": "View notification detail",
        "servlet_class": "NotificationServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='detail'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to customer/notificationDetail.jsp.\n"
             "Processing: Validates session. Reads 'id' param. Calls NotificationDAO.getNotificationById(id). Sets 'notification' attribute. Forwards to detail view."),
        ],
        "dao_class": "NotificationDAO",
        "dao_rows": [
            ("01", "getNotificationById(id)",
             "Inputs: int id.\n"
             "Outputs: Notification object or null.\n"
             "Processing: Executes SELECT * FROM notification WHERE notification_id = ?. Maps row to Notification model."),
        ],
    },

    # ── UC-29: Manage notification ────────────────────────────────────────────
    {
        "heading_contains": "Manage notification",
        "servlet_class": "NotificationServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='adminList'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/notifications.jsp with all notifications.\n"
             "Processing: Validates admin session. Calls NotificationDAO.getAllNotifications(). Sets 'notifications' attribute. Forwards to admin notification list."),
            ("02", "doPost(request, response) — action='create'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to notification list.\n"
             "Processing: Reads title, message, targetUserId (null = broadcast). Builds Notification object. Calls NotificationDAO.insertNotification(). Redirects."),
            ("03", "doPost(request, response) — action='update'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to notification list.\n"
             "Processing: Reads notificationId, updated title and message. Calls NotificationDAO.updateNotification(id, notification). Redirects."),
            ("04", "doPost(request, response) — action='delete'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to notification list.\n"
             "Processing: Reads 'id' param. Calls NotificationDAO.deleteNotification(id). Redirects."),
        ],
        "dao_class": "NotificationDAO",
        "dao_rows": [
            ("01", "insertNotification(notification)",
             "Inputs: Notification object.\n"
             "Outputs: void.\n"
             "Processing: Executes INSERT INTO notification (title, message, target_user_id, created_at)."),
            ("02", "updateNotification(id, notification)",
             "Inputs: int id, Notification object.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE notification SET title=?, message=? WHERE notification_id=?."),
            ("03", "deleteNotification(id)",
             "Inputs: int id.\n"
             "Outputs: void.\n"
             "Processing: Executes DELETE FROM notification WHERE notification_id = ?."),
        ],
    },

    # ── UC-30: Manage user ────────────────────────────────────────────────────
    {
        "heading_contains": "Manage user",
        "servlet_class": "UserServlet / AdminServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='list'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to admin/users.jsp with user list.\n"
             "Processing: Validates admin session. Calls UserDAO.getAllUsers(). Sets 'users' attribute. Forwards to user management list."),
            ("02", "doPost(request, response) — action='update'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to user list with success message.\n"
             "Processing: Reads userId, fullName, email, phone, role. Builds User. Calls UserDAO.updateUserById(). Redirects."),
            ("03", "doPost(request, response) — action='delete'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to user list with success message.\n"
             "Processing: Reads 'id' param. Calls UserDAO.deleteSoft(id). Redirects to user list."),
        ],
        "dao_class": "UserDAO",
        "dao_rows": [
            ("01", "getAllUsers()",
             "Inputs: None.\n"
             "Outputs: List<User>.\n"
             "Processing: Executes SELECT * FROM [user] WHERE is_deleted = 0 ORDER BY role, full_name. Maps all rows to User model."),
            ("02", "deleteSoft(id)",
             "Inputs: int id.\n"
             "Outputs: boolean.\n"
             "Processing: Executes UPDATE [user] SET is_deleted = 1 WHERE user_id = ?."),
        ],
    },

    # ── UC-31: Manage price category ──────────────────────────────────────────
    {
        "heading_contains": "Manage price category",
        "servlet_class": "PriceServlet",
        "servlet_rows": [
            ("01", "doGet(request, response) — action='categories'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Forward to owner/priceCategories.jsp with category list.\n"
             "Processing: Validates admin session. Calls PriceDAO.getAllPriceCategories(). Sets 'categories' attribute. Forwards to price category management view."),
            ("02", "doPost(request, response) — action='insertPrice'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to price list.\n"
             "Processing: Reads categoryId, unitPrice, effectiveDate. Builds PriceHistory. Calls PriceDAO.insertPrice(). Redirects to price list."),
            ("03", "doPost(request, response) — action='updatePrice'",
             "Inputs: HttpServletRequest, HttpServletResponse.\n"
             "Outputs: Redirect to price list.\n"
             "Processing: Reads priceId, unitPrice, effectiveDate. Calls PriceDAO.updatePrice(). Redirects."),
        ],
        "dao_class": "PriceDAO",
        "dao_rows": [
            ("01", "getAllPriceCategories()",
             "Inputs: None.\n"
             "Outputs: List<PriceCategory>.\n"
             "Processing: Executes SELECT * FROM price_category ORDER BY category_name. Maps rows to PriceCategory model."),
            ("02", "insertPrice(priceHistory)",
             "Inputs: PriceHistory object.\n"
             "Outputs: void.\n"
             "Processing: Executes INSERT INTO price_history (category_id, unit_price, effective_date)."),
            ("03", "updatePrice(priceHistory)",
             "Inputs: PriceHistory object.\n"
             "Outputs: void.\n"
             "Processing: Executes UPDATE price_history SET unit_price=?, effective_date=? WHERE price_id=?."),
            ("04", "getCurrentPrice(categoryId)",
             "Inputs: int categoryId.\n"
             "Outputs: BigDecimal — current unit price.\n"
             "Processing: Executes SELECT unit_price FROM price_history WHERE category_id = ? ORDER BY effective_date DESC LIMIT 1."),
        ],
    },
]

# ─────────────────────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────────────────────

def clone_table(template_table):
    """Deep-copy a table element."""
    return copy.deepcopy(template_table._tbl)

def build_class_spec_table(doc, class_name, rows, template_tbl):
    """
    Build a new table mirroring template_tbl style.
    Strategy: clone full template, preserve tblPr + tblGrid, rebuild all rows.
    """
    from docx.table import Table
    W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

    # 1. Deep-clone the template and fix IDs immediately
    tbl_elem = fix_ids(copy.deepcopy(template_tbl._tbl))

    # 2. Remove ONLY w:tr elements - preserve w:tblPr, w:tblGrid, etc.
    for tr in tbl_elem.findall(f'{{{W}}}tr'):
        tbl_elem.remove(tr)

    # 3. Get row templates from the ORIGINAL (avoid double-clone ID issues)
    orig_rows = template_tbl._tbl.findall(f'{{{W}}}tr')
    header_src  = orig_rows[0]
    datarow_src = orig_rows[1] if len(orig_rows) >= 2 else orig_rows[0]

    def make_row(texts, is_bold=False):
        tr = fix_ids(copy.deepcopy(datarow_src))
        cells = tr.findall(f'{{{W}}}tc')
        for ci, tc in enumerate(cells):
            for p in tc.findall(f'{{{W}}}p'):
                tc.remove(p)
            text = texts[ci] if ci < len(texts) else ''
            for line in text.split(chr(10)):
                p_el = etree.SubElement(tc, f'{{{W}}}p')
                if line.strip():
                    r_el = etree.SubElement(p_el, f'{{{W}}}r')
                    if is_bold:
                        rPr = etree.SubElement(r_el, f'{{{W}}}rPr')
                        etree.SubElement(rPr, f'{{{W}}}b')
                    t_el = etree.SubElement(r_el, f'{{{W}}}t')
                    t_el.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
                    t_el.text = line
        return tr

    # 4. Banner row: class name bold in first cell
    tbl_elem.append(make_row([class_name, '', ''], is_bold=True))

    # 5. Header row: No | Method | Description
    tbl_elem.append(fix_ids(copy.deepcopy(header_src)))

    # 6. Data rows
    for no, method, desc in rows:
        tbl_elem.append(make_row([no, method, desc]))

    return Table(tbl_elem, doc)

def find_class_spec_insert_positions(doc):
    """
    Returns list of (paragraph_element, uc_heading_text) for all
    'b. Class Specifications' paragraphs that are NOT followed by a table.
    """
    body = doc.element.body
    children = list(body)
    results = []

    for i, el in enumerate(children):
        tag = el.tag.split('}')[-1]
        if tag != 'p':
            continue
        text = ''.join(el.itertext()).strip()
        # Deduplicate text (word sometimes triples it)
        if 'b. Class Specifications' not in text:
            continue
        # Check if next non-empty sibling is a table
        next_is_table = False
        for j in range(i+1, min(i+4, len(children))):
            next_tag = children[j].tag.split('}')[-1]
            if next_tag == 'tbl':
                next_is_table = True
                break
            if next_tag == 'p':
                next_text = ''.join(children[j].itertext()).strip()
                if next_text and 'c. Sequence Diagram' in next_text:
                    break  # clearly empty, no table

        if not next_is_table:
            # Find the UC heading (Heading 2) before this
            uc_heading = ''
            for k in range(i-1, max(0, i-10), -1):
                prev_el = children[k]
                if prev_el.tag.split('}')[-1] == 'p':
                    prev_text = ''.join(prev_el.itertext()).strip()
                    if prev_text and 'b. Class' not in prev_text and 'a. Class' not in prev_text:
                        uc_heading = prev_text
                        break
            results.append((el, uc_heading))

    return results


# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────
def main():
    doc = Document(INPUT_PATH)
    template_tbl = doc.tables[3]  # UC-1 Register servlet class spec table

    positions = find_class_spec_insert_positions(doc)
    print(f"Found {len(positions)} empty Class Specification sections.")

    insert_count = 0
    for (spec_para_el, uc_heading) in positions:
        # Find matching spec data
        spec = None
        for s in UC_SPECS:
            contains = s["heading_contains"].lower()
            uc_lower = uc_heading.lower()
            uc_clean = uc_lower[:len(uc_lower)//3 + 5] if len(uc_lower) > 20 else uc_lower
            if contains in uc_clean:
                if "heading_not_contains" in s:
                    excl = s["heading_not_contains"].lower()
                    if excl in uc_clean:
                        continue
                spec = s
                break

        if spec is None:
            print(f"  [SKIP] No spec data for: {uc_heading[:60]}")
            continue

        print(f"  [INSERT] {uc_heading[:60]}")

        servlet_tbl = build_class_spec_table(doc, f"Class Name: {spec['servlet_class']}", spec['servlet_rows'], template_tbl)
        dao_tbl     = build_class_spec_table(doc, f"Class Name: {spec['dao_class']}",     spec['dao_rows'],     template_tbl)

        body = doc.element.body
        spec_idx = list(body).index(spec_para_el)

        # Order inserted (bottom-up): dao_tbl → mid paragraph → servlet_tbl
        body.insert(spec_idx + 1, dao_tbl._tbl)

        mid_p = OxmlElement('w:p')
        mid_r = OxmlElement('w:r')
        mid_t = OxmlElement('w:t')
        mid_t.text = 'Class Methods'
        mid_r.append(mid_t)
        mid_p.append(mid_r)
        body.insert(spec_idx + 1, mid_p)

        body.insert(spec_idx + 1, servlet_tbl._tbl)

        insert_count += 1

    # Final pass: make every w:id in the entire document unique
    print("Fixing all w:id attributes in document...")
    fix_ids(doc.element.body)

    print(f"\nInserted Class Specifications for {insert_count} use cases.")
    doc.save(OUTPUT_PATH)
    print(f"Saved to: {OUTPUT_PATH}")

if __name__ == '__main__':
    main()
