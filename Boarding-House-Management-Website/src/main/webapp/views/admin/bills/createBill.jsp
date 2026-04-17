<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Create Bill - AKDD House</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        .badge-room    { background:#0d6efd; }
        .badge-amenity { background:#6610f2; }
        .badge-utility { background:#198754; }
        .badge-service { background:#fd7e14; }
        .badge-manual  { background:#6c757d; }
        .line-total    { min-width:110px; }
        #totalDisplay  { font-size:1.3rem; font-weight:700; color:#198754; }
        .item-row td   { vertical-align:middle; }
    </style>
</head>
<body class="bg-light">
<%@ include file="../../navbar.jsp" %>

<div class="container-fluid">
<div class="row flex-nowrap admin-layout-row">
<%@ include file="../sidebar.jsp" %>
<main class="col admin-main px-4 py-4">

    <div class="d-flex align-items-center gap-3 mb-4">
        <a href="${pageContext.request.contextPath}/bill?action=list"
           class="btn btn-outline-secondary btn-sm">&#8592; Back</a>
        <h4 class="mb-0"><i class="bi bi-plus-circle me-2"></i>Create New Bill</h4>
    </div>

    <!-- Alert area -->
    <div id="alertArea"></div>

    <form id="billForm" method="post" action="${pageContext.request.contextPath}/bill?action=create">
    <div class="row g-4">

        <!-- Left: header fields -->
        <div class="col-md-5">
            <div class="card shadow-sm border-0">
                <div class="card-header fw-semibold">General Info</div>
                <div class="card-body">

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Contract / Room</label>
                        <select name="contractId" id="contractSelect" class="form-select" required>
                            <option value="">-- Select contract --</option>
                            <c:forEach var="c" items="${contracts}">
                                <option value="${c.contractId}">
                                    Room ${c.roomNumber} — ${c.primaryTenantName != null ? c.primaryTenantName : 'N/A'} (${c.status})
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Billing Period</label>
                        <input type="month" name="period" id="periodInput" class="form-control" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Due Date</label>
                        <input type="date" name="dueDate" id="dueDateInput" class="form-control" required>
                    </div>

                    <button type="button" id="autoFillBtn" class="btn btn-primary w-100">
                        <span id="autoFillSpinner" class="spinner-border spinner-border-sm d-none me-1"></span>
                        Auto-fill items
                    </button>
                    <div id="duplicateWarning" class="alert alert-warning mt-2 d-none">
                        Bill already exists for this contract in this period.
                    </div>
                </div>
            </div>
        </div>

        <!-- Right: bill items -->
        <div class="col-md-7">
            <div class="card shadow-sm border-0">
                <div class="card-header d-flex justify-content-between align-items-center fw-semibold">
                    <span>Bill Items</span>
                    <button type="button" id="addRowBtn" class="btn btn-sm btn-outline-secondary">
                        + Add Item Manually
                    </button>
                </div>
                <div class="card-body p-0">
                    <table class="table table-sm mb-0" id="itemsTable">
                        <thead class="table-light">
                        <tr>
                            <th style="width:90px">Type</th>
                            <th>Description</th>
                            <th style="width:80px">Qty</th>
                            <th style="width:110px">Unit Price</th>
                            <th style="width:110px">Total</th>
                            <th style="width:40px"></th>
                        </tr>
                        </thead>
                        <tbody id="itemsBody">
                        <!-- rows injected by JS -->
                        </tbody>
                        <tfoot>
                        <tr class="table-light fw-bold">
                            <td colspan="4" class="text-end pe-3">TOTAL:</td>
                            <td><span id="totalDisplay">0 &#8363;</span></td>
                            <td></td>
                        </tr>
                        </tfoot>
                    </table>
                </div>
                <div class="card-footer">
                    <input type="hidden" name="totalAmount" id="hiddenTotal" value="0">
                    <button type="submit" class="btn btn-success w-100 fw-semibold">
                        <i class="bi bi-save me-1"></i>Save Bill
                    </button>
                </div>
            </div>
        </div>

    </div>
    </form>

</main>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
const contextPath = '${pageContext.request.contextPath}';

// =============================
// INIT: default period = current month, due = +10 days
// =============================
(function initDefaults() {
    const now = new Date();
    const y = now.getFullYear();
    const m = String(now.getMonth() + 1).padStart(2, '0');
    document.getElementById('periodInput').value = y + '-' + m;
    updateDueDate();
})();

function updateDueDate() {
    const period = document.getElementById('periodInput').value;
    if (!period) return;
    const d = new Date(period + '-01');
    d.setDate(d.getDate() + 10);
    document.getElementById('dueDateInput').value = d.toISOString().slice(0, 10);
}

document.getElementById('periodInput').addEventListener('change', function () {
    updateDueDate();
    checkDuplicate();
});
document.getElementById('contractSelect').addEventListener('change', checkDuplicate);

// =============================
// DUPLICATE CHECK via AJAX
// =============================
function checkDuplicate() {
    const cid    = document.getElementById('contractSelect').value;
    const period = document.getElementById('periodInput').value;
    const warn   = document.getElementById('duplicateWarning');
    if (!cid || !period) { warn.classList.add('d-none'); return; }
    fetch(contextPath + '/bill?action=checkDuplicate&contractId=' + cid + '&period=' + period)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.exists) warn.classList.remove('d-none');
            else             warn.classList.add('d-none');
        })
        .catch(function() {});
}

// =============================
// AUTO-FILL
// =============================
document.getElementById('autoFillBtn').addEventListener('click', function () {
    const cid    = document.getElementById('contractSelect').value;
    const period = document.getElementById('periodInput').value;
    const btn    = this;

    if (!cid)    { showAlert('Please select a contract first.', 'warning');    return; }
    if (!period) { showAlert('Please select a billing period.', 'warning'); return; }

    document.getElementById('autoFillSpinner').classList.remove('d-none');
    btn.disabled = true;

    fetch(contextPath + '/bill/preview?contractId=' + cid + '&period=' + period)
        .then(function(r) {
            if (!r.ok) throw new Error('Server error ' + r.status);
            return r.json();
        })
        .then(function(items) {
            clearRows();
            items.forEach(function(item) { addRow(item); });
            recalcTotal();
            showAlert('Auto-filled ' + items.length + ' item(s).', 'success');
        })
        .catch(function(err) { showAlert('Failed to load data: ' + err.message, 'danger'); })
        .finally(function() {
            document.getElementById('autoFillSpinner').classList.add('d-none');
            btn.disabled = false;
        });
});

// =============================
// ROW MANAGEMENT
// =============================
let rowIndex = 0;

const BADGE_CLASS  = { room:'badge-room', amenity:'badge-amenity', utility:'badge-utility', service:'badge-service', manual:'badge-manual' };
const BADGE_LABEL  = { room:'Room', amenity:'Amenity', utility:'Utility', service:'Service', manual:'Manual' };

function addRow(item) {
    const i      = rowIndex++;
    const tbody  = document.getElementById('itemsBody');
    const tr     = document.createElement('tr');
    tr.className = 'item-row';
    tr.dataset.index = i;

    const src   = (item && item.sourceType) ? item.sourceType : 'manual';
    const srcId = (item && item.sourceId)   ? item.sourceId   : '';
    const catId = (item && item.categoryId) ? item.categoryId : 1;
    const desc  = (item && item.description) ? item.description : '';
    const qty   = (item && item.quantity)   ? item.quantity   : '1';
    const price = (item && item.unitPrice)  ? item.unitPrice  : '0';
    const line  = (parseFloat(qty) * parseFloat(price)) || 0;

    const bClass = BADGE_CLASS[src] || 'badge-manual';
    const bLabel = BADGE_LABEL[src] || 'Other';

    tr.innerHTML =
        '<td>' +
            '<span class="badge ' + bClass + ' text-white">' + bLabel + '</span>' +
            '<input type="hidden" name="itemSourceType[]" value="' + escAttr(src) + '">' +
            '<input type="hidden" name="itemSourceId[]"   value="' + escAttr(String(srcId)) + '">' +
            '<input type="hidden" name="itemCategoryId[]" value="' + escAttr(String(catId)) + '">' +
        '</td>' +
        '<td><input type="text"   name="itemDesc[]"  class="form-control form-control-sm item-desc"  value="' + escAttr(desc) + '" placeholder="Description..." required></td>' +
        '<td><input type="number" name="itemQty[]"   class="form-control form-control-sm item-qty"   value="' + qty + '" step="0.01" min="0.01" required></td>' +
        '<td><input type="number" name="itemPrice[]" class="form-control form-control-sm item-price" value="' + price + '" step="1" min="0" required></td>' +
        '<td class="line-total fw-semibold">' + fmtVnd(line) + '</td>' +
        '<td><button type="button" class="btn btn-sm btn-outline-danger btn-delete-row">×</button></td>';

    tbody.appendChild(tr);

    tr.querySelector('.item-qty').addEventListener('input',   function() { updateLine(tr); recalcTotal(); });
    tr.querySelector('.item-price').addEventListener('input', function() { updateLine(tr); recalcTotal(); });
    tr.querySelector('.btn-delete-row').addEventListener('click', function() { tr.remove(); recalcTotal(); });
}

function clearRows() {
    document.getElementById('itemsBody').innerHTML = '';
    rowIndex = 0;
}

function updateLine(tr) {
    const qty   = parseFloat(tr.querySelector('.item-qty').value)   || 0;
    const price = parseFloat(tr.querySelector('.item-price').value) || 0;
    tr.querySelector('.line-total').innerHTML = fmtVnd(qty * price);
}

function recalcTotal() {
    let total = 0;
    document.querySelectorAll('.item-row').forEach(function(tr) {
        const qty   = parseFloat(tr.querySelector('.item-qty').value)   || 0;
        const price = parseFloat(tr.querySelector('.item-price').value) || 0;
        total += qty * price;
    });
    document.getElementById('totalDisplay').innerHTML = fmtVnd(total);
    document.getElementById('hiddenTotal').value = Math.round(total);
}

document.getElementById('addRowBtn').addEventListener('click', function() {
    addRow({ sourceType: 'manual' });
});

// =============================
// FORM SUBMIT GUARD
// =============================
document.getElementById('billForm').addEventListener('submit', function(e) {
    const rows = document.querySelectorAll('.item-row');
    if (rows.length === 0) {
        e.preventDefault();
        showAlert('Please add at least 1 bill item.', 'warning');
        return;
    }
    if (!document.getElementById('duplicateWarning').classList.contains('d-none')) {
        e.preventDefault();
        showAlert('Bill already exists for this period. Duplicate not allowed.', 'danger');
    }
});

// =============================
// HELPERS
// =============================
function fmtVnd(n) {
    return Math.round(n).toLocaleString('vi-VN') + ' &#8363;';
}
function escAttr(s) {
    if (!s) return '';
    return s.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
function showAlert(msg, type) {
    const area = document.getElementById('alertArea');
    area.innerHTML = '<div class="alert alert-' + type + ' alert-dismissible fade show" role="alert">' +
        msg + '<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>';
    area.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}
</script>
<%@ include file="../../footer.jsp" %>
</body>
</html>
