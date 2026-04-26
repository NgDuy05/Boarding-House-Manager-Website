<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<t:layout>

    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/utility">Utilities</a>
            </li>
            <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/utility?action=detail&id=${utility.utilityId}">
                    ${utility.utilityName}
                </a>
            </li>
            <li class="breadcrumb-item active">Add Usage Record</li>
        </ol>
    </nav>

    <div class="row justify-content-center">
        <div class="col-lg-6">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white border-bottom py-3">
                    <h5 class="mb-0 fw-semibold">
                        <i class="bi bi-plus-circle text-primary me-2"></i>
                        Add Usage Record — ${utility.utilityName}
                    </h5>
                </div>
                <div class="card-body p-4">

                    <%-- Error: new reading < old reading --%>
                    <c:if test="${param.error == 'invalid_reading'}">
                        <div class="alert alert-danger d-flex align-items-center mb-3">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i>
                            New reading (<strong>${param.newValue}</strong>) must be greater than or equal to the old reading (<strong>${param.oldValue}</strong>).
                        </div>
                    </c:if>

                    <form method="post" action="${pageContext.request.contextPath}/utility"
                          onsubmit="return validateReadings(this)">
                        <input type="hidden" name="action" value="insertUsage">
                        <input type="hidden" name="utilityId" value="${utility.utilityId}">

                        <%-- Room --%>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                Room <span class="text-danger">*</span>
                            </label>
                            <select name="roomId" id="roomSelect" class="form-select" required
                                    onchange="fetchLatestUsage(this.value)">
                                <option value="">-- Select Room --</option>
                                <c:forEach var="room" items="${rooms}">
                                    <option value="${room.roomId}">Room ${room.roomNumber}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <%-- Previous reading info box (hidden by default) --%>
                        <div id="prevReadingBox" class="alert alert-info d-flex align-items-start gap-2 mb-3"
                             style="display:none !important;">
                            <i class="bi bi-info-circle-fill mt-1 flex-shrink-0"></i>
                            <div class="small">
                                <div class="fw-semibold mb-1">Previous Period Reading</div>
                                Period: <strong id="prevPeriod">—</strong> &nbsp;|&nbsp;
                                Last Reading: <strong id="prevNewValue">—</strong>
                                <span class="text-muted">${utility.unit}</span>
                                <div class="text-muted mt-1">→ Old Reading has been auto-filled.</div>
                            </div>
                        </div>

                        <div id="noReadingBox" class="alert alert-warning d-flex align-items-center gap-2 mb-3"
                             style="display:none !important;">
                            <i class="bi bi-exclamation-circle-fill flex-shrink-0"></i>
                            <span class="small">This room has no previous ${utility.utilityName} records. Please enter the Old Reading manually.</span>
                        </div>

                        <%-- Period --%>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">
                                Period <span class="text-danger">*</span>
                            </label>
                            <input type="date" name="period" id="periodInput" class="form-control" required>
                            <div class="form-text">First day of the billing month (e.g. 2026-01-01).</div>
                        </div>

                        <%-- Readings --%>
                        <div class="row g-3 mb-4">
                            <div class="col-6">
                                <label class="form-label fw-semibold">
                                    Old Reading (${utility.unit}) <span class="text-danger">*</span>
                                </label>
                                <div class="input-group">
                                    <input type="number" name="oldValue" id="oldValueInput"
                                           class="form-control" placeholder="0" min="0" required>
                                    <span id="lockIcon" class="input-group-text"
                                          title="Auto-filled from previous month"
                                          style="display:none; background:#e9ecef; cursor:default;">
                                        <i class="bi bi-lock-fill text-secondary"></i>
                                    </span>
                                </div>
                            </div>
                            <div class="col-6">
                                <label class="form-label fw-semibold">
                                    New Reading (${utility.unit}) <span class="text-danger">*</span>
                                </label>
                                <input type="number" name="newValue" id="newValueInput"
                                       class="form-control" placeholder="0" min="0" required>
                            </div>
                        </div>

                        <%-- Consumption preview --%>
                        <div id="consumptionPreview" class="mb-3" style="display:none;">
                            <div class="p-2 rounded border bg-light small">
                                Consumption:
                                <strong id="consumptionValue" class="ms-1">—</strong>
                                <span class="text-muted ms-1">${utility.unit}</span>
                            </div>
                        </div>

                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-primary px-4">
                                <i class="bi bi-check-circle me-1"></i>Save Record
                            </button>
                            <a href="${pageContext.request.contextPath}/utility?action=detail&id=${utility.utilityId}"
                               class="btn btn-outline-secondary px-4">
                                <i class="bi bi-x-circle me-1"></i>Cancel
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

<script>
const utilityId   = ${utility.utilityId};
const contextPath = '${pageContext.request.contextPath}';

// Default period = 1st day of the current month
(function () {
    const p = document.getElementById('periodInput');
    if (!p.value) {
        const now = new Date();
        const y   = now.getFullYear();
        const m   = String(now.getMonth() + 1).padStart(2, '0');
        p.value   = y + '-' + m + '-01';
    }
})();

// AJAX when selecting a room -> fetch last month's reading
function fetchLatestUsage(roomId) {
    const prevBox  = document.getElementById('prevReadingBox');
    const noBox    = document.getElementById('noReadingBox');
    const oldInput = document.getElementById('oldValueInput');
    const lockIcon = document.getElementById('lockIcon');

    // Reset
    prevBox.style.setProperty('display', 'none', 'important');
    noBox.style.setProperty('display',   'none', 'important');
    oldInput.readOnly = false;
    oldInput.classList.remove('bg-light');
    lockIcon.style.display = 'none';

    if (!roomId) return;

    fetch(contextPath + '/utility?action=getLatestUsage&roomId=' + roomId + '&utilityId=' + utilityId)
        .then(r => r.json())
        .then(data => {
            if (data && data.newValue !== undefined) {
                // Has reading -> auto-fill oldValue and lock field
                oldInput.value    = data.newValue;
                oldInput.readOnly = true;
                oldInput.classList.add('bg-light');
                lockIcon.style.display = 'flex';

                // Format previous period
                let periodLabel = data.period || '';
                try {
                    const d = new Date(data.period);
                    periodLabel = d.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });
                } catch (e) {}
                document.getElementById('prevPeriod').textContent  = periodLabel;
                document.getElementById('prevNewValue').textContent = data.newValue;
                prevBox.style.removeProperty('display');

                // Suggest period = next month after the last period
                suggestNextPeriod(data.period);
            } else {
                // No reading found
                oldInput.value = '';
                noBox.style.removeProperty('display');
            }
            updateConsumption();
        })
        .catch(() => {
            oldInput.readOnly = false;
            oldInput.classList.remove('bg-light');
        });
}

// Suggest period = next month
function suggestNextPeriod(lastPeriodStr) {
    try {
        const d = new Date(lastPeriodStr);
        d.setMonth(d.getMonth() + 1);
        d.setDate(1);
        const y = d.getFullYear();
        const m = String(d.getMonth() + 1).padStart(2, '0');
        document.getElementById('periodInput').value = y + '-' + m + '-01';
    } catch (e) {}
}

// Calculate consumption in real-time
document.getElementById('newValueInput').addEventListener('input', updateConsumption);
document.getElementById('oldValueInput').addEventListener('input', updateConsumption);

function updateConsumption() {
    const oldVal  = parseInt(document.getElementById('oldValueInput').value) || 0;
    const newVal  = parseInt(document.getElementById('newValueInput').value);
    const preview = document.getElementById('consumptionPreview');
    const el      = document.getElementById('consumptionValue');

    if (!isNaN(newVal)) {
        const used    = newVal - oldVal;
        el.textContent = used;
        el.style.color = used >= 0 ? '#0d6efd' : '#dc3545';
        preview.style.display = 'block';
    } else {
        preview.style.display = 'none';
    }
}

// Validate before submit
function validateReadings(form) {
    const oldVal = parseInt(form.oldValue.value) || 0;
    const newVal = parseInt(form.newValue.value) || 0;
    if (newVal < oldVal) {
        alert('New reading (' + newVal + ') must be >= old reading (' + oldVal + ')');
        form.newValue.focus();
        return false;
    }
    return true;
}
</script>

</t:layout>