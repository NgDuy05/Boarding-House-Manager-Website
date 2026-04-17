<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<t:layout>

    <!-- HEADER -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2><i class="bi bi-tags me-2"></i>Categories Price</h2>

        <a href="${pageContext.request.contextPath}/price?action=create"
           class="btn btn-primary">
            <i class="bi bi-plus-circle me-1"></i> Add Category
        </a>
    </div>

    <!-- FILTER -->
    <c:set var="type" value="${param.type}" />

    <ul class="nav nav-tabs mb-3">

        <li class="nav-item">
            <a class="nav-link ${empty type ? 'active' : ''}"
               href="${pageContext.request.contextPath}/price?action=categories">
                All
            </a>
        </li>

        <!-- RENT -->
        <li class="nav-item">
            <a class="nav-link ${type == 'rent' ? 'active' : ''}"
               href="?action=categories&type=rent">
                <span class="badge bg-primary">Rent</span>
            </a>
        </li>

        <!-- UTILITY -->
        <li class="nav-item">
            <a class="nav-link ${type == 'utility' ? 'active' : ''}"
               href="?action=categories&type=utility">
                <span class="badge bg-info text-dark">Utility</span>
            </a>
        </li>

        <!-- SERVICE -->
        <li class="nav-item">
            <a class="nav-link ${type == 'service' ? 'active' : ''}"
               href="?action=categories&type=service">
                <span class="badge bg-success">Service</span>
            </a>
        </li>

        <!-- FACILITY -->
        <li class="nav-item">
            <a class="nav-link ${type == 'facility' ? 'active' : ''}"
               href="?action=categories&type=facility">
                <span class="badge bg-secondary">Facility</span>
            </a>
        </li>

    </ul>

    <!-- TABLE -->
    <div class="card shadow-sm">
        <div class="card-body p-0">

            <table class="table table-hover table-striped mb-0 align-middle">

                <thead class="table-dark">
                    <tr>
                        <th style="width: 60px;">#</th>
                        <th>Category Code</th>
                        <th>Type</th>
                        <th>Unit</th>
                        <th>Current Price</th>
                        <th>Future Price</th>
                        <th class="text-center" style="width:150px;">Action</th>
                    </tr>
                </thead>

                <tbody>

                    <c:forEach var="cat" items="${categories}" varStatus="s">

                        <tr>

                            <td>${s.index + 1}</td>

                            <td>
                                <i class="bi bi-tag me-1 text-secondary"></i>
                                <strong>${cat.categoryCode}</strong>
                            </td>

                            <!-- TYPE -->
                            <td>
                                <span class="badge
                                    ${cat.categoryType == 'rent' ? 'bg-primary' :
                                      cat.categoryType == 'utility' ? 'bg-info text-dark' :
                                      cat.categoryType == 'service' ? 'bg-success' :
                                      'bg-secondary'}">
                                    ${cat.categoryType}
                                </span>
                            </td>

                            <td>${cat.unit}</td>

                            <!-- CURRENT -->
                            <td>
                                <c:choose>
                                    <c:when test="${currentMap[cat.categoryId] != null}">
                                        <strong class="text-success">
                                            <fmt:formatNumber value="${currentMap[cat.categoryId]}" type="number"/>đ
                                        </strong>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">--đ</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <!-- FUTURE -->
                            <td>
                                <c:choose>
                                    <c:when test="${futureMap[cat.categoryId] != null}">
                                        <span class="text-warning">
                                            <fmt:formatNumber value="${futureMap[cat.categoryId]}" type="number"/>đ
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">--đ</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <!-- ACTION -->
                            <td class="text-center">

                                <a href="price?action=edit&id=${cat.categoryId}"
                                   class="btn btn-sm btn-warning">
                                    <i class="bi bi-pencil"></i>
                                </a>

                                <a href="price?action=delete&id=${cat.categoryId}"
                                   class="btn btn-sm btn-danger"
                                   onclick="return confirm('Delete this category?');">
                                    <i class="bi bi-trash"></i>
                                </a>

                            </td>

                        </tr>

                    </c:forEach>

                    <!-- EMPTY -->
                    <c:if test="${empty categories}">
                        <tr>
                            <td colspan="7" class="text-center text-muted py-5">
                                <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                                No price categories found.
                            </td>
                        </tr>
                    </c:if>

                </tbody>

            </table>

        </div>

        <div class="card-footer text-muted">
            Total: <strong>${fn:length(categories)}</strong> category(ies)
        </div>
    </div>

</t:layout>