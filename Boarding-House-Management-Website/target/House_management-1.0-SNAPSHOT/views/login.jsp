<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Login - AKDD House</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        /* 1. Import Font Pretendard */
        @import url("https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css");

        /* 2. Ocean Palette Variables */
        :root {
            --ocean-900: #03045E;
            --ocean-800: #023E8A;
            --ocean-700: #0077B6;
            --ocean-600: #0096C7;
            --ocean-500: #00B4D8;
            --ocean-400: #48CAE4;
            --ocean-300: #90E0EF;
            --ocean-200: #ADE8F4;
            --ocean-100: #CAF0F8;
            --ds-bg: #f4f7f9;
            --ds-text: #292A2D;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Pretendard', sans-serif !important;
            min-height: 100vh;
            display: flex;
            overflow-x: hidden;
            background-color: var(--ds-bg);
        }

        /* ── Left Panel (Brand & Info) ── */
        .auth-panel-left {
            flex: 0 0 45%;
            background: linear-gradient(145deg, var(--ocean-900) 0%, var(--ocean-800) 50%, var(--ocean-700) 100%);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 3rem;
            position: relative;
            overflow: hidden;
        }
        .auth-panel-left::before {
            content: ''; position: absolute;
            width: 400px; height: 400px;
            background: rgba(255,255,255,.05); border-radius: 50%;
            top: -100px; left: -100px;
        }
        .auth-panel-left::after {
            content: ''; position: absolute;
            width: 300px; height: 300px;
            background: rgba(255,255,255,.04); border-radius: 50%;
            bottom: -50px; right: -50px;
        }
        .left-inner { position: relative; z-index: 1; color: #fff; max-width: 380px; }
        .left-inner .brand-icon {
            width: 80px; height: 80px;
            background: rgba(255,255,255,.15);
            border-radius: 24px; border: 2px solid rgba(255,255,255,.3);
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 1.5rem; backdrop-filter: blur(10px);
        }
        .left-inner h1 { font-size: 2.2rem; font-weight: 800; margin-bottom: .8rem; letter-spacing: -0.5px; }
        .left-inner p  { font-size: 1rem; opacity: .85; line-height: 1.6; margin-bottom: 2.5rem; }
        
        .feature-list  { list-style: none; text-align: left; }
        .feature-list li {
            display: flex; align-items: center; gap: 1rem;
            margin-bottom: 1.25rem; font-size: .95rem; opacity: .9; font-weight: 500;
        }
        .feature-list li .fi {
            width: 36px; height: 36px;
            background: rgba(255,255,255,.15);
            border-radius: 10px; border: 1px solid rgba(255,255,255,0.2);
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0; font-size: 1.1rem;
        }

        /* ── Right Panel (Form) ── */
        .auth-panel-right {
            flex: 1;
            background: var(--ds-bg);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            overflow-y: auto;
        }
        .auth-form-wrap {
            width: 100%;
            max-width: 440px;
            background: #fff;
            border-radius: 24px;
            padding: 3rem;
            box-shadow: 0 10px 40px rgba(0,0,0,.06);
            animation: slideUp .4s ease both;
        }
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .auth-form-wrap h2 { font-size: 1.7rem; font-weight: 800; color: var(--ocean-900); letter-spacing: -0.5px; margin-bottom: 0.2rem; }
        .auth-form-wrap .sub { color: #64748b; font-size: .95rem; margin-bottom: 2rem; font-weight: 500; }

        .form-label { font-weight: 700; font-size: .85rem; color: #374151; margin-bottom: .4rem; }

        .input-icon-wrap { position: relative; }
        .input-icon-wrap .icon-left {
            position: absolute; top: 50%; left: 16px;
            transform: translateY(-50%);
            color: #9ca3af; pointer-events: none; font-size: 1rem;
        }
        .input-icon-wrap input {
            padding-left: 2.8rem;
            border: 1.5px solid #e5e7eb;
            border-radius: 12px;
            font-size: .95rem;
            height: 48px;
            transition: border-color .2s, box-shadow .2s;
            width: 100%;
        }
        .input-icon-wrap input:focus {
            border-color: var(--ocean-500);
            box-shadow: 0 0 0 3px rgba(0, 180, 216, 0.15);
            outline: none;
        }

        .btn-eye {
            position: absolute; top: 50%; right: 12px;
            transform: translateY(-50%);
            background: none; border: none;
            color: #9ca3af; cursor: pointer; font-size: 1.1rem;
            padding: 4px; line-height: 1;
        }
        .btn-eye:hover { color: var(--ocean-600); }

        .forgot-link {
            font-size: .85rem; color: var(--ocean-700);
            text-decoration: none; font-weight: 600; transition: color 0.2s;
        }
        .forgot-link:hover { color: var(--ocean-900); text-decoration: underline; }

        .btn-submit {
            width: 100%; height: 50px;
            background: linear-gradient(135deg, var(--ocean-800), var(--ocean-600));
            border: none; border-radius: 12px;
            color: #fff; font-weight: 700; font-size: 1rem;
            cursor: pointer; transition: transform .2s, box-shadow .2s;
            display: flex; align-items: center; justify-content: center; gap: .5rem;
        }
        .btn-submit:hover  { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0, 119, 182, 0.25); }
        .btn-submit:active { transform: scale(.98); }

        .divider {
            display: flex; align-items: center; gap: .75rem;
            color: #9ca3af; font-size: .85rem; font-weight: 500; margin: 1.5rem 0;
        }
        .divider::before, .divider::after {
            content: ''; flex: 1; height: 1px; background: #e5e7eb;
        }

        .switch-link { font-size: .9rem; color: #64748b; text-align: center; }
        .switch-link a { color: var(--ocean-700); font-weight: 700; text-decoration: none; transition: color 0.2s; }
        .switch-link a:hover { color: var(--ocean-900); text-decoration: underline; }

        /* ── Toast ── */
        .toast-wrap {
            position: fixed; top: 24px; right: 24px; z-index: 9999;
            display: flex; flex-direction: column; gap: .5rem;
        }
        .toast-item {
            display: flex; align-items: flex-start; gap: .75rem;
            padding: 1rem 2.5rem 1rem 1.25rem;
            border-radius: 12px;
            box-shadow: 0 8px 30px rgba(0,0,0,.14);
            min-width: 300px; max-width: 380px;
            position: relative; background: #fff;
            animation: toastIn .35s ease both;
        }
        .toast-item.success { border-left: 4px solid #10b981; }
        .toast-item.error   { border-left: 4px solid #ef4444; }
        .toast-icon  { font-size: 1.25rem; flex-shrink: 0; margin-top: 1px; }
        .toast-item.success .toast-icon { color: #10b981; }
        .toast-item.error   .toast-icon { color: #ef4444; }
        .toast-title { font-weight: 700; font-size: .88rem; color: #111827; line-height: 1.3; }
        .toast-msg   { font-size: .82rem; color: #6b7280; margin-top: 2px; line-height: 1.4; }
        .toast-close {
            position: absolute; top: 8px; right: 10px;
            background: none; border: none; cursor: pointer;
            color: #9ca3af; font-size: .85rem; line-height: 1;
        }
        .toast-close:hover { color: #374151; }
        .toast-progress {
            position: absolute; bottom: 0; left: 0; height: 3px;
            border-radius: 0 0 0 12px;
            animation: shrink 4.5s linear forwards;
        }
        .toast-item.success .toast-progress { background: #10b981; }
        .toast-item.error   .toast-progress { background: #ef4444; }
        
        @keyframes toastIn {
            from { opacity: 0; transform: translateX(30px); }
            to   { opacity: 1; transform: translateX(0); }
        }
        @keyframes shrink { from { width: 100%; } to { width: 0; } }
        .toast-item.hiding { animation: toastOut .3s ease forwards; }
        @keyframes toastOut { to { opacity: 0; transform: translateX(30px); } }

        @media (max-width: 992px) {
            .auth-panel-left { display: none; }
            .auth-panel-right { background: linear-gradient(145deg, var(--ocean-900), var(--ocean-700)); }
            .auth-form-wrap { box-shadow: 0 10px 40px rgba(0,0,0,.2); padding: 2.5rem; }
        }
    </style>
</head>
<body>

<div class="auth-panel-left">
    <div class="left-inner">
        <div class="brand-icon">
            <i class="bi bi-buildings-fill fs-2 text-white"></i>
        </div>
        <h1>AKDD House</h1>
        <p>Smart boarding house management — simple, fast and secure.</p>
        <ul class="feature-list">
            <li>
                <span class="fi"><i class="bi bi-shield-check"></i></span>
                Secure account protection
            </li>
            <li>
                <span class="fi"><i class="bi bi-bell-fill"></i></span>
                Instant bill notifications
            </li>
            <li>
                <span class="fi"><i class="bi bi-graph-up-arrow"></i></span>
                Easy contract tracking
            </li>
            <li>
                <span class="fi"><i class="bi bi-headset"></i></span>
                24/7 responsive support
            </li>
        </ul>
    </div>
</div>

<div class="auth-panel-right">
    <div class="auth-form-wrap">

        <h2>Welcome back!</h2>
        <p class="sub">Sign in to continue to your account</p>

        <form action="${pageContext.request.contextPath}/auth" method="post" novalidate>
            <input type="hidden" name="action" value="login">

            <div class="mb-3">
                <label class="form-label">Username</label>
                <div class="input-icon-wrap">
                    <i class="bi bi-person-fill icon-left"></i>
                    <input type="text" name="username" class="form-control"
                           placeholder="Enter your username"
                           value="${param.username}" required autofocus>
                </div>
            </div>

            <div class="mb-2">
                <label class="form-label">Password</label>
                <div class="input-icon-wrap">
                    <i class="bi bi-lock-fill icon-left"></i>
                    <input type="password" name="password" id="loginPassword"
                           class="form-control" placeholder="Enter your password" required>
                    <button class="btn-eye" type="button" onclick="togglePwd('loginPassword','eyeLogin')">
                        <i class="bi bi-eye" id="eyeLogin"></i>
                    </button>
                </div>
            </div>
            
            <div class="text-end mb-4">
                <a href="${pageContext.request.contextPath}/auth?action=forgetPassword" class="forgot-link">
                    Forgot password?
                </a>
            </div>

            <button type="submit" class="btn-submit">
                <i class="bi bi-box-arrow-in-right me-1"></i> Sign In
            </button>
        </form>

        <div class="divider">or</div>

        <p class="switch-link">
            Don't have an account?
            <a href="${pageContext.request.contextPath}/auth?action=register">Register now</a>
        </p>

    </div>
</div>

<div class="toast-wrap" id="toastWrap"></div>

<%-- Pass server messages to JS as data attributes to avoid template-literal conflicts --%>
<div id="serverData"
     data-success="<c:out value='${sessionScope.successMessage}' default='' />"
     data-error="<c:out value='${error}' default='' />"
     style="display:none"></div>
<c:if test="${not empty sessionScope.successMessage}">
    <% session.removeAttribute("successMessage"); %>
</c:if>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function togglePwd(inputId, iconId) {
        const inp  = document.getElementById(inputId);
        const icon = document.getElementById(iconId);
        if (inp.type === 'password') {
            inp.type = 'text';
            icon.classList.replace('bi-eye', 'bi-eye-slash');
        } else {
            inp.type = 'password';
            icon.classList.replace('bi-eye-slash', 'bi-eye');
        }
    }

    function showToast(type, title, message) {
        const wrap = document.getElementById('toastWrap');

        const item = document.createElement('div');
        item.className = 'toast-item ' + type;

        const icon = document.createElement('i');
        icon.className = 'bi toast-icon ' + (type === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-circle-fill');

        const body = document.createElement('div');

        const titleEl = document.createElement('div');
        titleEl.className = 'toast-title';
        titleEl.textContent = title;

        const msgEl = document.createElement('div');
        msgEl.className = 'toast-msg';
        msgEl.textContent = message;

        body.appendChild(titleEl);
        body.appendChild(msgEl);

        const closeBtn = document.createElement('button');
        closeBtn.className = 'toast-close';
        closeBtn.setAttribute('aria-label', 'Close');
        closeBtn.innerHTML = '<i class="bi bi-x-lg"></i>';
        closeBtn.onclick = function() { dismissToast(item); };

        const progress = document.createElement('div');
        progress.className = 'toast-progress';

        item.appendChild(icon);
        item.appendChild(body);
        item.appendChild(closeBtn);
        item.appendChild(progress);
        wrap.appendChild(item);

        const timer = setTimeout(function() { dismissToast(item); }, 4500);
        item._timer = timer;
    }

    function dismissToast(el) {
        if (!el || el.classList.contains('hiding')) return;
        clearTimeout(el._timer);
        el.classList.add('hiding');
        setTimeout(function() { el.remove(); }, 320);
    }

    document.addEventListener('DOMContentLoaded', function() {
        const data    = document.getElementById('serverData');
        const success = data.dataset.success.trim();
        const error   = data.dataset.error.trim();

        if (success) showToast('success', 'Welcome!', success);
        if (error)   showToast('error',   'Login Failed', error);
    });
</script>
</body>
</html>