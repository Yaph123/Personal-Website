<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true"%>
<!DOCTYPE html>
<html>
<head>
    <title>TMTickets</title>
    <meta charset="UTF-8">
    <style>
        :root {
            --tm-purple: #6a5acd;
            --tm-deep-purple: #4b3fb0;
            --tm-accent: #ff7c4d;
            --tm-accent-dark: #f06435;
            --tm-bg-dark: #111322;
            --tm-bg-card: #1a1d2f;
            --tm-text-main: #f5f5ff;
            --tm-text-muted: #a7b1d9;
            --tm-success: #3dd68c;
            --tm-danger: #ff5c7a;
        }

        * {
            box-sizing: border-box;
        }

        body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            margin: 0;
            background: radial-gradient(circle at top left, #22254b, #05060b 55%, #0f172a 90%);
            color: var(--tm-text-main);
            min-height: 100vh;
        }

        /* Page frame with glow */
        .page-frame {
            max-width: 1200px;
            margin: 24px auto;
            border-radius: 18px;
            border: 1px solid rgba(255,255,255,0.07);
            background: radial-gradient(circle at top, #262b55, #111322);
            box-shadow:
                0 0 0 1px rgba(255,255,255,0.02),
                0 24px 60px rgba(0,0,0,0.65),
                0 0 120px rgba(143,143,248,0.35);
            overflow: hidden;
            position: relative;
        }

        /* subtle animated glow blobs */
        .page-frame::before,
        .page-frame::after {
            content: "";
            position: absolute;
            width: 260px;
            height: 260px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(255,124,77,0.4), transparent 60%);
            mix-blend-mode: screen;
            filter: blur(6px);
            opacity: 0.6;
            animation: floatGlow 18s ease-in-out infinite alternate;
            pointer-events: none;
        }
        .page-frame::before {
            top: -120px;
            left: -80px;
        }
        .page-frame::after {
            bottom: -140px;
            right: -40px;
            background: radial-gradient(circle, rgba(143,143,248,0.4), transparent 60%);
            animation-delay: 4s;
        }

        @keyframes floatGlow {
            0%   { transform: translate(0,0) scale(1);   opacity: 0.5; }
            50%  { transform: translate(40px, 20px) scale(1.1); opacity: 0.75; }
            100% { transform: translate(-20px, -30px) scale(1.05); opacity: 0.55; }
        }

        /* NAVBAR */
        .navbar {
            background: linear-gradient(135deg, var(--tm-deep-purple), #272464);
            color: #ffffff;
            padding: 14px 28px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 14px;
            position: relative;
            z-index: 2;
        }
        .nav-left {
            font-weight: 700;
            font-size: 18px;
            letter-spacing: 0.06em;
            text-transform: uppercase;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .nav-logo-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: radial-gradient(circle, #ffdab9, var(--tm-accent));
            box-shadow: 0 0 12px rgba(255,124,77,0.9);
            animation: pulseDot 2.4s ease-in-out infinite;
        }
        @keyframes pulseDot {
            0%, 100% { transform: scale(1);   opacity: 0.85; }
            50%      { transform: scale(1.4); opacity: 1; }
        }

        .nav-right a {
            color: #f8f9ff;
            margin-left: 18px;
            text-decoration: none;
            cursor: pointer;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            position: relative;
            padding-bottom: 4px;
        }
        .nav-right a::after {
            content: "";
            position: absolute;
            left: 0;
            bottom: 0;
            width: 0;
            height: 2px;
            background: linear-gradient(90deg, var(--tm-accent), #ffe082);
            transition: width 0.22s ease-out;
        }
        .nav-right a:hover::after {
            width: 100%;
        }

        .container {
            padding: 26px 40px 36px 40px;
            max-width: 1200px;
            margin: 0 auto;
            position: relative;
            z-index: 1;
        }

        /* Section fade animation */
        .section {
            animation: fadeInUp 0.45s ease-out;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translate3d(0, 14px, 0);
            }
            to {
                opacity: 1;
                transform: translate3d(0, 0, 0);
            }
        }

        /* HOME / SEARCH CARD */
        .search-bar {
            background: radial-gradient(circle at top left, #383f7b, #21253f);
            color: #f8f8ff;
            padding: 26px 32px 26px 32px;
            border-radius: 18px;
            margin: 8px auto 26px auto;
            max-width: 720px;
            box-shadow:
                0 14px 35px rgba(0,0,0,0.6),
                0 0 0 1px rgba(255,255,255,0.04);
            position: relative;
            overflow: hidden;
        }
        .search-bar::before {
            content: "Find your next night out";
            position: absolute;
            right: -40px;
            top: 10px;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.18em;
            color: rgba(255,255,255,0.18);
            transform: rotate(12deg);
        }

        .search-title {
            text-align: left;
            font-size: 26px;
            margin: 0 0 4px 0;
            font-weight: 700;
        }
        .search-subtitle {
            font-size: 13px;
            color: var(--tm-text-muted);
            margin-bottom: 14px;
        }
        .search-line {
            border: none;
            border-top: 1px solid rgba(255,255,255,0.08);
            margin-bottom: 16px;
        }
        .search-fields-row {
            display: flex;
            gap: 18px;
            flex-wrap: wrap;
        }
        .field {
            margin-top: 8px;
            flex: 1;
            min-width: 180px;
        }
        .label {
            font-weight: 600;
            font-size: 12px;
            color: #c9e8ff;
            text-transform: uppercase;
            letter-spacing: 0.1em;
        }
        .search-bar input {
            width: 100%;
            padding: 9px 11px;
            border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.14);
            background: rgba(6,8,20,0.75);
            color: #f5f5ff;
            box-sizing: border-box;
            margin-top: 4px;
            font-size: 13px;
            outline: none;
            transition: border-color 0.22s ease, box-shadow 0.22s ease, background 0.22s ease;
        }
        .search-bar input::placeholder {
            color: rgba(199,210,254,0.55);
        }
        .search-bar input:focus {
            border-color: rgba(255,124,77,0.9);
            box-shadow: 0 0 0 1px rgba(255,124,77,0.6);
            background: rgba(6,8,20,0.98);
        }

        .search-button-row {
            display: flex;
            justify-content: flex-end;
            margin-top: 20px;
            gap: 10px;
            align-items: center;
        }

        /* Button styles */
        .btn {
            padding: 8px 18px;
            background: var(--tm-deep-purple);
            color: white;
            border: none;
            cursor: pointer;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 600;
            letter-spacing: 0.06em;
            text-transform: uppercase;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: transform 0.15s ease, box-shadow 0.15s ease, background 0.15s ease;
            box-shadow: 0 8px 20px rgba(0,0,0,0.5);
        }
        .btn span.btn-icon {
            font-size: 16px;
            line-height: 1;
        }
        .btn.orange {
            background: linear-gradient(135deg, var(--tm-accent), #ffd085);
            color: #230c06;
            box-shadow: 0 10px 26px rgba(255,124,77,0.45);
        }
        .btn.orange:hover {
            background: linear-gradient(135deg, var(--tm-accent-dark), #ffc46b);
            transform: translateY(-1px) scale(1.02);
            box-shadow: 0 14px 30px rgba(255,124,77,0.55);
        }
        .btn:hover {
            transform: translateY(-1px) scale(1.02);
        }
        .btn:active {
            transform: translateY(0) scale(0.99);
            box-shadow: 0 4px 12px rgba(0,0,0,0.6);
        }

        /* RESULTS TABLE */
        .results-wrapper {
            margin-top: 10px;
            border-radius: 16px;
            overflow: hidden;
            background: rgba(10,12,28,0.9);
            border: 1px solid rgba(255,255,255,0.04);
            box-shadow: 0 14px 35px rgba(0,0,0,0.75);
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: transparent;
        }
        thead th {
            background: linear-gradient(90deg, #1e223e, #161827);
            font-weight: 600;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: #aeb7f1;
            border-bottom: 1px solid rgba(255,255,255,0.06);
        }
        th, td {
            border-bottom: 1px solid rgba(255,255,255,0.04);
            padding: 9px 12px;
            text-align: left;
            font-size: 13px;
        }
        tbody tr {
            transition: background 0.18s ease, transform 0.18s ease, box-shadow 0.18s ease;
        }
        tbody tr:nth-child(even) {
            background: rgba(15,18,40,0.90);
        }
        tbody tr:nth-child(odd) {
            background: rgba(8,10,24,0.90);
        }
        tbody tr:hover {
            background: radial-gradient(circle at left, rgba(255,124,77,0.25), rgba(17,24,39,0.96));
            cursor: pointer;
            transform: translateY(-1px);
            box-shadow: 0 12px 28px rgba(0,0,0,0.75);
        }

        /* EVENT DETAILS PANEL */
        .event-details {
            background: radial-gradient(circle at top left, #404885, #1a1d32);
            color: #f9f9ff;
            padding: 22px 26px 24px 26px;
            margin: 26px auto 0 auto;
            border-radius: 18px;
            max-width: 880px;
            box-shadow:
                0 16px 40px rgba(0,0,0,0.75),
                0 0 0 1px rgba(255,255,255,0.05);
            position: relative;
            overflow: hidden;
            animation: fadeInUp 0.35s ease-out;
        }
        .event-details::before {
            content: "Event overview";
            position: absolute;
            left: -26px;
            bottom: 6px;
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 0.24em;
            color: rgba(255,255,255,0.16);
            transform: rotate(-8deg);
        }
        .event-details-title {
            font-size: 22px;
            text-align: left;
            margin-bottom: 12px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
        }
        .event-pill {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.16em;
            padding: 3px 10px;
            border-radius: 999px;
            background: rgba(11, 227, 145, 0.16);
            border: 1px solid rgba(61,214,140,0.6);
            color: #b1ffe0;
        }

        .event-details-cols {
            display: flex;
            justify-content: space-between;
            gap: 26px;
            flex-wrap: wrap;
        }
        .event-details-left .label {
            color: #c9e8ff;
        }
        .event-details-left div,
        .event-details-right div {
            margin-top: 10px;
            font-size: 13px;
        }
        .event-details-right input {
            width: 100%;
            padding: 9px 10px;
            border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.14);
            background: rgba(6,8,20,0.9);
            color: #f5f5ff;
            margin-top: 4px;
            font-size: 13px;
            outline: none;
        }
        .event-details-right input:focus {
            border-color: rgba(61,214,140,0.9);
            box-shadow: 0 0 0 1px rgba(61,214,140,0.7);
        }
        .event-details-right .btn {
            margin-top: 16px;
            width: 100%;
            justify-content: center;
        }

        .star {
            font-size: 22px;
            cursor: pointer;
            margin-left: 6px;
            transition: transform 0.2s ease, text-shadow 0.2s ease, color 0.2s ease;
            color: rgba(255,255,255,0.35);
        }
        .star:hover {
            transform: scale(1.15);
            text-shadow: 0 0 12px rgba(255,215,0,0.8);
            color: #ffe083;
        }
        .star.filled {
            color: #ffd54f;
            text-shadow: 0 0 12px rgba(255,215,0,0.9);
        }

        /* LOGIN / SIGNUP */
        #loginSection {
            margin-top: 10px;
        }
        .login-signup {
            display: flex;
            gap: 32px;
            margin-top: 14px;
            flex-wrap: wrap;
        }
        .login-column {
            flex: 1;
            min-width: 260px;
            background: rgba(8,10,24,0.95);
            border-radius: 16px;
            padding: 20px 20px 22px 20px;
            box-shadow:
                0 10px 26px rgba(0,0,0,0.65),
                0 0 0 1px rgba(255,255,255,0.04);
            position: relative;
            overflow: hidden;
        }
        .login-column::before {
            content: "";
            position: absolute;
            right: -40px;
            top: -40px;
            width: 140px;
            height: 140px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(255,124,77,0.25), transparent 55%);
            opacity: 0.7;
        }
        .login-column h2 {
            margin-top: 0;
            margin-bottom: 6px;
            color: #e5e7ff;
        }
        .login-tagline {
            font-size: 12px;
            color: var(--tm-text-muted);
            margin-bottom: 10px;
        }
        .login-column input {
            width: 100%;
            padding: 9px 10px;
            border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.14);
            background: rgba(10,12,28,0.95);
            color: #f5f5ff;
            box-sizing: border-box;
            margin-top: 4px;
            font-size: 13px;
            outline: none;
        }
        .login-column input:focus {
            border-color: rgba(143,143,248,0.9);
            box-shadow: 0 0 0 1px rgba(143,143,248,0.8);
        }
        .login-column .field {
            margin-top: 12px;
        }
        .login-column .btn {
            margin-top: 18px;
            width: 160px;
            background: linear-gradient(135deg, #ff5c7a, #ff9c6a);
            box-shadow: 0 12px 28px rgba(255,92,122,0.55);
            justify-content: center;
        }

        /* FAVORITES */
        #favoritesSection h2,
        #walletSection h2 {
            color: #e5e7ff;
            margin-top: 10px;
            margin-bottom: 6px;
        }
        #favoritesSection h2::after,
        #walletSection h2::after {
            content: "";
            display: inline-block;
            margin-left: 10px;
            width: 52px;
            height: 2px;
            background: linear-gradient(90deg, var(--tm-accent), transparent);
            vertical-align: middle;
        }

        .card {
            background: rgba(10,12,28,0.98);
            padding: 14px 16px 14px 16px;
            border-radius: 14px;
            margin-top: 14px;
            position: relative;
            box-shadow:
                0 12px 30px rgba(0,0,0,0.75),
                0 0 0 1px rgba(255,255,255,0.04);
            display: flex;
            flex-direction: column;
            transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease;
        }
        .card:hover {
            transform: translateY(-2px);
            box-shadow: 0 16px 42px rgba(0,0,0,0.85);
            border-color: rgba(255,255,255,0.12);
        }
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 18px;
        }
        .card-main {
            display: flex;
            flex-direction: column;
        }
        .card-title {
            font-weight: 600;
            font-size: 15px;
        }
        .card-date {
            font-size: 12px;
            color: var(--tm-text-muted);
            margin-top: 2px;
        }
        .card-price {
            font-weight: 600;
            font-size: 13px;
            color: #ffcf7f;
        }
        .card .close {
            position: absolute;
            right: 12px;
            top: 10px;
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            color: rgba(255,255,255,0.55);
            transition: color 0.2s ease, transform 0.1s ease;
        }
        .card .close:hover {
            color: var(--tm-danger);
            transform: scale(1.1);
        }
        .fav-details {
            margin-top: 12px;
            border-top: 1px dashed rgba(255,255,255,0.07);
            padding-top: 10px;
        }

        /* WALLET */
        .wallet-summary {
            margin-top: 10px;
            margin-bottom: 18px;
            padding: 12px 14px;
            border-radius: 14px;
            background: radial-gradient(circle at left, rgba(61,214,140,0.16), rgba(10,12,28,0.96));
            display: flex;
            gap: 24px;
            flex-wrap: wrap;
        }
        .wallet-summary-row {
            font-size: 13px;
        }
        .wallet-summary-row .label {
            font-weight: 600;
            color: #c8e6ff;
        }
        .wallet-summary-row span[id^="cash"],
        .wallet-summary-row span[id^="totalAccount"] {
            font-weight: 600;
        }

        .wallet-card {
            background: rgba(8,10,24,0.98);
            padding: 18px 18px 16px 18px;
            border-radius: 16px;
            margin: 16px auto 0 auto;
            border: 1px solid rgba(255,255,255,0.04);
            box-shadow:
                0 14px 36px rgba(0,0,0,0.8),
                0 0 0 1px rgba(255,255,255,0.02);
            max-width: 880px;
            transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease;
        }
        .wallet-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 20px 50px rgba(0,0,0,0.9);
            border-color: rgba(255,255,255,0.1);
        }
        .wallet-title {
            font-weight: 600;
            margin-bottom: 4px;
            font-size: 15px;
        }
        .wallet-venue {
            font-size: 12px;
            color: var(--tm-text-muted);
            margin-bottom: 10px;
        }
        .wallet-stats-wrapper {
            display: flex;
            justify-content: center;
            margin-top: 4px;
            margin-bottom: 14px;
        }
        .wallet-stats {
            border-collapse: collapse;
            font-size: 12px;
            min-width: 100%;
        }
        .wallet-stats th,
        .wallet-stats td {
            border: 1px solid rgba(255,255,255,0.08);
            padding: 6px 12px;
            text-align: center;
        }
        .wallet-stats th {
            background: rgba(31,41,79,0.9);
            font-weight: 600;
            color: #c5ccff;
        }

        .wallet-trade {
            text-align: center;
            margin-top: 6px;
        }
        .wallet-trade-row {
            margin-top: 8px;
            font-size: 13px;
        }
        .wallet-trade input[type="number"] {
            width: 80px;
            padding: 7px 8px;
            border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.18);
            background: rgba(11,15,35,0.98);
            color: #f5f5ff;
            outline: none;
        }
        .wallet-trade input[type="number"]:focus {
            border-color: rgba(143,143,248,0.9);
        }
        .wallet-trade label {
            margin: 0 10px;
            font-size: 13px;
        }
        .wallet-trade input[type="radio"] {
            accent-color: var(--tm-accent);
        }

        .wallet-submit-btn {
            margin-top: 10px;
            padding: 7px 22px;
            border-radius: 999px;
            border: none;
            background: linear-gradient(135deg, #3dd68c, #11b97b);
            color: #02110a;
            cursor: pointer;
            font-weight: 600;
            font-size: 13px;
            letter-spacing: 0.06em;
            text-transform: uppercase;
            box-shadow: 0 12px 30px rgba(17,185,123,0.45);
            transition: transform 0.15s ease, box-shadow 0.15s ease, background 0.15s ease;
        }
        .wallet-submit-btn:hover {
            transform: translateY(-1px) scale(1.02);
            box-shadow: 0 16px 40px rgba(17,185,123,0.6);
        }
        .wallet-submit-btn:active {
            transform: translateY(0) scale(0.99);
            box-shadow: 0 8px 20px rgba(0,0,0,0.6);
        }

        .hidden {
            display: none;
        }
    </style>

    <script>
        let loggedIn = false;
        let currentUser = null;
        let currentEvent = null;   // last clicked event (search or favorite)
        let favoriteIds = new Set();

        async function init() {
            try {
                const resp = await fetch('tmtickets?action=userInfo');
                const data = await resp.json();
                if (data.loggedIn) {
                    loggedIn = true;
                    currentUser = data.username;
                }
            } catch (e) {}
            updateNavbar();
            showHome();
        }

        function updateNavbar() {
            const navLoggedOut = document.getElementById('navLoggedOut');
            const navLoggedIn  = document.getElementById('navLoggedIn');
            if (loggedIn) {
                navLoggedOut.classList.add('hidden');
                navLoggedIn.classList.remove('hidden');
            } else {
                navLoggedOut.classList.remove('hidden');
                navLoggedIn.classList.add('hidden');
            }
        }

        function hideAllSections() {
            document.getElementById('homeSection').classList.add('hidden');
            document.getElementById('loginSection').classList.add('hidden');
            document.getElementById('favoritesSection').classList.add('hidden');
            document.getElementById('walletSection').classList.add('hidden');
        }

        function showHome() {
            hideAllSections();
            document.getElementById('homeSection').classList.remove('hidden');
        }

        function showLogin() {
            hideAllSections();
            document.getElementById('loginSection').classList.remove('hidden');
        }

        async function showFavorites() {
            if (!loggedIn) { alert("Please log in"); return; }
            hideAllSections();
            document.getElementById('favoritesSection').classList.remove('hidden');
            await loadFavorites();
        }

        async function showWallet() {
            if (!loggedIn) { alert("Please log in"); return; }
            hideAllSections();
            document.getElementById('walletSection').classList.remove('hidden');
            await loadWallet();
        }

        /* ============ searches =========================================================== */

        async function doSearch() {
            const keyword = document.getElementById('keyword').value.trim();
            const city    = document.getElementById('city').value.trim();

            if (!keyword || !city) {
                alert("Please enter both keyword and location");
                return;
            }

            const url = "https://us-central1-quixotic-dynamo-165616.cloudfunctions.net/getEvents/search"
                + "?keyword=" + encodeURIComponent(keyword)
                + "&city=" + encodeURIComponent(city);

            const resp = await fetch(url);
            const data = await resp.json();

            const tbody = document.getElementById('resultsBody');
            tbody.innerHTML = "";
            currentEvent = null;
            document.getElementById('eventDetails').innerHTML = "";

            data.forEach(ev => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>${ev.localDate}</td>
                    <td><img src="${ev.images}" alt="icon" style="height:50px;border-radius:10px;box-shadow:0 4px 10px rgba(0,0,0,0.5);object-fit:cover;"></td>
                    <td>${ev.name}</td>
                    <td>${ev.venue}</td>
                `;
                if (loggedIn) {
                    tr.addEventListener('click', () => showEventDetails(ev));
                }
                tbody.appendChild(tr);
            });
        }

        // show details either under search table or under a favorite
        async function showEventDetails(ev, targetId, starId) {
            const eventId = ev.eventId || ev.id;
            currentEvent = { ...ev, eventId: eventId };

            const detailsDiv = document.getElementById(targetId || 'eventDetails');
            const starIdFinal = starId || 'favStar_home';

            const url = "https://us-central1-quixotic-dynamo-165616.cloudfunctions.net/getEvents/eventDetail/"
                + encodeURIComponent(eventId);

            const resp = await fetch(url);
            const d = await resp.json();

            let minP = d.price && d.price.min;
            let maxP = d.price && d.price.max;
            let priceRangeStr = "";
            let disabled = "";

            if (minP === -1 || maxP === -1) {
                priceRangeStr = "N/A";
                minP = null;
                maxP = null;
                disabled = "disabled";
            } else {
                priceRangeStr = minP + " - " + maxP;
            }

            const starClass = favoriteIds.has(eventId) ? "star filled" : "star";

            detailsDiv.innerHTML = `
                <div class="event-details">
                    <div class="event-details-title">
                        <div>${d.event.name}</div>
                        <div style="display:flex;align-items:center;gap:10px;">
                            <span class="event-pill">Live Event</span>
                            <span id="${starIdFinal}" class="${starClass}"
                                  onclick="toggleFavoriteFromDetails('${eventId}','${starIdFinal}',${minP},${maxP})">
                                  &#9733;
                            </span>
                        </div>
                    </div>
                    <div class="event-details-cols">
                        <div class="event-details-left">
                            <div><span class="label">Date &amp; Time</span><br>${d.date.localDate} ${d.date.localTime}</div>
                            <div><span class="label">Venue</span><br>${d.event.venue}</div>
                            <div><span class="label">Price Range (USD)</span><br>${priceRangeStr}</div>
                            <div><span class="label">More Info</span><br>
                                <a href="${d.event.url}" target="_blank" style="color:#bfeef0;text-decoration:none;">
                                    View on Ticketmaster &rarr;
                                </a>
                            </div>
                        </div>
                        <div class="event-details-right">
                            <div><span class="label">Quantity of Tickets to Purchase</span><br>
                                <input id="buyQty" type="number" min="1">
                            </div>
                            <div>
                                <button class="btn orange"
                                        onclick="purchaseTickets(${minP},${maxP})"
                                        ${disabled}>
                                    <span class="btn-icon">⚡</span> Purchase
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            `;
        }

        async function purchaseTickets(minPrice, maxPrice) {
            if (minPrice == null || maxPrice == null) {
                alert("FAILED: Purchase not possible");
                return;
            }
            const qtyStr = document.getElementById('buyQty').value;
            const qty = parseInt(qtyStr);
            if (!qty || qty < 1) {
                alert("FAILED: Purchase not possible");
                return;
            }

            const params = new URLSearchParams();
            params.append("action", "purchase");
            params.append("eventId", currentEvent.eventId);
            params.append("name", currentEvent.name);
            params.append("venue", currentEvent.venue);
            params.append("minPrice", minPrice);
            params.append("maxPrice", maxPrice);
            params.append("quantity", qty);

            const resp = await fetch("tmtickets", {
                method: "POST",
                headers: {"Content-Type":"application/x-www-form-urlencoded"},
                body: params.toString()
            });
            const data = await resp.json();
            if (!data.success) {
                alert("FAILED: Purchase not possible");
            }
            // on success, no alert; wallet will show changes later
        }

        // favorites star from details (search / favorites)
        async function toggleFavoriteFromDetails(eventId, starId, minPrice, maxPrice) {
            if (!currentEvent) return;

            const params = new URLSearchParams();
            params.append("action", "toggleFavorite");
            params.append("eventId", eventId);
            params.append("name", currentEvent.name);
            params.append("localDate", currentEvent.localDate || "");
            params.append("venue", currentEvent.venue || "");

            if (minPrice == null || maxPrice == null || isNaN(minPrice) || isNaN(maxPrice)) {
                params.append("minPrice", "N/A");
                params.append("maxPrice", "N/A");
            } else {
                params.append("minPrice", minPrice);
                params.append("maxPrice", maxPrice);
            }

            const resp = await fetch("tmtickets", {
                method: "POST",
                headers: {"Content-Type":"application/x-www-form-urlencoded"},
                body: params.toString()
            });
            const data = await resp.json();
            if (data.success) {
                if (data.removed) {
                    favoriteIds.delete(eventId);
                } else {
                    favoriteIds.add(eventId);
                }
                const star = document.getElementById(starId);
                if (star) {
                    star.className = favoriteIds.has(eventId) ? "star filled" : "star";
                }
            } else {
                alert(data.message || "Favorite action failed");
            }
        }

        /* ============ login signup ============ */

        async function doSignup() {
            const email = document.getElementById('suEmail').value.trim();
            const username = document.getElementById('suUsername').value.trim();
            const pw1 = document.getElementById('suPassword').value;
            const pw2 = document.getElementById('suPassword2').value;

            if (!email || !username || !pw1 || !pw2) {
                alert("All fields required");
                return;
            }
            if (pw1 !== pw2) {
                alert("Passwords do not match");
                return;
            }

            const params = new URLSearchParams();
            params.append("action", "signup");
            params.append("email", email);
            params.append("username", username);
            params.append("password", pw1);

            const resp = await fetch("tmtickets", {
                method:"POST",
                headers:{"Content-Type":"application/x-www-form-urlencoded"},
                body: params.toString()
            });
            const data = await resp.json();
            if (data.success) {
                loggedIn = true;
                currentUser = data.username;
                updateNavbar();
                showHome();
            } else {
                alert(data.message || "Sign up failed");
            }
        }

        async function doLogin() {
            const username = document.getElementById('liUsername').value.trim();
            const password = document.getElementById('liPassword').value;

            if (!username || !password) {
                alert("All fields required");
                return;
            }

            const params = new URLSearchParams();
            params.append("action","login");
            params.append("username", username);
            params.append("password", password);

            const resp = await fetch("tmtickets", {
                method:"POST",
                headers:{"Content-Type":"application/x-www-form-urlencoded"},
                body: params.toString()
            });
            const data = await resp.json();
            if (data.success) {
                loggedIn = true;
                currentUser = data.username;
                updateNavbar();
                showHome();
            } else {
                alert(data.message || "Login failed");
            }
        }

        async function doLogout() {
            await fetch("tmtickets?action=logout");
            loggedIn = false;
            currentUser = null;
            favoriteIds.clear();
            updateNavbar();
            showHome();
        }

        /* ============ favourites ============ */

        async function loadFavorites() {
            const container = document.getElementById('favoritesList');
            container.innerHTML = "";

            const resp = await fetch("tmtickets?action=favorites");
            const data = await resp.json();
            if (!data.success) {
                return;
            }

            const favs = data.favorites;
            if (!favs || favs.length === 0) {
                return;
            }
            favoriteIds = new Set(favs.map(f => f.eventId));

            favs.forEach(f => {
                const card = document.createElement('div');
                card.className = "card";
                card.innerHTML = `
                    <div class="card-header">
                        <div class="card-main">
                            <div class="card-title">${f.name}</div>
                            <div class="card-date">${f.localDate || ""}</div>
                        </div>
                        <div class="card-price">${f.minPrice} - ${f.maxPrice}</div>
                        <div class="close" onclick="removeFavorite('${f.eventId}')">×</div>
                    </div>
                    <div id="favDetails_${f.eventId}" class="fav-details"></div>
                `;

                card.addEventListener('click', (e) => {
                    // don't treat clicking the X as "open details"
                    if (e.target.classList.contains('close')) return;

                    const ev = {
                        eventId: f.eventId,
                        id: f.eventId,
                        name: f.name,
                        localDate: f.localDate,
                        venue: f.venue,
                        images: ""
                    };

                    currentEvent = ev;
                    showEventDetails(ev, 'favDetails_' + f.eventId, 'favStar_' + f.eventId);
                });

                container.appendChild(card);
            });
        }

        async function removeFavorite(eventId) {
            const params = new URLSearchParams();
            params.append("action","toggleFavorite");
            params.append("eventId", eventId);
            params.append("name","_");
            params.append("localDate","");
            params.append("venue","");
            params.append("minPrice","0");
            params.append("maxPrice","0");

            const resp = await fetch("tmtickets", {
                method:"POST",
                headers:{"Content-Type":"application/x-www-form-urlencoded"},
                body: params.toString()
            });
            const data = await resp.json();
            if (data.success && data.removed) {
                favoriteIds.delete(eventId);
                loadFavorites();
            }
        }

        /* ============ wallet ============ */

        async function loadWallet() {
            const resp = await fetch("tmtickets?action=wallet");
            const data = await resp.json();
            if (!data.success) { alert("Error loading wallet"); return; }

            document.getElementById('cashBalance').innerText = data.cashBalance.toFixed(2);
            document.getElementById('totalAccountValue').innerText = data.totalAccountValue.toFixed(2);

            const container = document.getElementById('walletPositions');
            container.innerHTML = "";
            if (!data.positions || data.positions.length === 0) {
                container.innerHTML = "<p style='font-size:13px;color:rgba(226,232,255,0.8);margin-top:6px;'>You have no tickets yet. Head to <strong>Home</strong> to start building your wallet.</p>";
                return;
            }

            data.positions.forEach(p => {
                const safeName  = p.name.replace(/\"/g,'');
                const safeVenue = p.venue.replace(/\"/g,'');

                const card = document.createElement('div');
                card.className = "wallet-card";
                card.innerHTML = `
                    <div class="wallet-title">${p.name}</div>
                    <div class="wallet-venue">${p.venue}</div>
                    <div class="wallet-stats-wrapper">
                        <table class="wallet-stats">
                            <tr>
                                <th>Quantity</th>
                                <td>${p.quantity}</td>
                                <th>Change</th>
                                <td>${p.change.toFixed(2)}</td>
                            </tr>
                            <tr>
                                <th>Average Cost / Ticket</th>
                                <td>${p.avgCost.toFixed(2)}</td>
                                <th>Current Price</th>
                                <td>${p.maxPrice.toFixed(2)}</td>
                            </tr>
                            <tr>
                                <th>Total Cost</th>
                                <td>${p.totalCost.toFixed(2)}</td>
                                <th>Market Value</th>
                                <td>${p.marketValue.toFixed(2)}</td>
                            </tr>
                        </table>
                    </div>
                    <div class="wallet-trade">
                        <div class="wallet-trade-row">
                            <span class="label">Quantity</span>
                            <input type="number" min="1" id="qty_${p.eventId}">
                        </div>
                        <div class="wallet-trade-row">
                            <label><input type="radio" name="side_${p.eventId}" value="BUY" checked> BUY</label>
                            <label><input type="radio" name="side_${p.eventId}" value="SELL"> SELL</label>
                        </div>
                        <button class="wallet-submit-btn"
                            onclick="submitTrade('${p.eventId}','${safeName}', '${safeVenue}', ${p.minPrice}, ${p.maxPrice})">
                            Submit
                        </button>
                    </div>
                `;
                container.appendChild(card);
            });
        }

        async function submitTrade(eventId, name, venue, minPrice, maxPrice) {
            const qtyInput = document.getElementById('qty_' + eventId);
            const qty = parseInt(qtyInput.value);
            if (!qty || qty < 1) {
                alert("FAILED: transaction not possible");
                return;
            }
            const sideInputs = document.getElementsByName('side_' + eventId);
            let side = "BUY";
            for (const r of sideInputs) {
                if (r.checked) { side = r.value; break; }
            }

            const params = new URLSearchParams();
            params.append("action","trade");
            params.append("side", side);
            params.append("eventId", eventId);
            params.append("name", name);
            params.append("venue", venue);
            params.append("minPrice", minPrice);
            params.append("maxPrice", maxPrice);
            params.append("quantity", qty);

            const resp = await fetch("tmtickets", {
                method:"POST",
                headers:{"Content-Type":"application/x-www-form-urlencoded"},
                body: params.toString()
            });
            const data = await resp.json();
            if (data.success) {
                // just reload wallet to show new values / removed row
                loadWallet();
            } else {
                alert("FAILED: transaction not possible");
            }
        }
    </script>
</head>

<body onload="init()">
<div class="page-frame">
    <div class="navbar">
        <div class="nav-left">
            <span class="nav-logo-dot"></span>
            <span>TMTickets</span>
        </div>
        <div class="nav-right">
            <span id="navLoggedOut">
                <a onclick="showHome()">Home</a>
                <a onclick="showLogin()">Login / Sign Up</a>
            </span>
            <span id="navLoggedIn" class="hidden">
                <a onclick="showHome()">Home</a>
                <a onclick="showFavorites()">Favorites</a>
                <a onclick="showWallet()">Wallet</a>
                <a onclick="doLogout()">Logout</a>
            </span>
        </div>
    </div>

    <div class="container">

        <!-- HOME / SEARCH -->
        <div id="homeSection" class="section">
            <div class="search-bar">
                <h2 class="search-title">Events Search</h2>
                <div class="search-subtitle">Search Ticketmaster events by artist, event name, and city.</div>
                <hr class="search-line">
                <div class="search-fields-row">
                    <div class="field">
                        <span class="label">Keyword</span><br>
                        <input id="keyword" type="text" placeholder="Artist or event">
                    </div>
                    <div class="field">
                        <span class="label">Location</span><br>
                        <input id="city" type="text" placeholder="City">
                    </div>
                </div>
                <div class="search-button-row">
                    <button class="btn orange" onclick="doSearch()">
                        <span class="btn-icon">🔍</span>
                        Search
                    </button>
                </div>
            </div>

            <div class="results-wrapper">
                <table>
                    <thead>
                    <tr>
                        <th>Date</th>
                        <th>Icon</th>
                        <th>Event</th>
                        <th>Venue</th>
                    </tr>
                    </thead>
                    <tbody id="resultsBody">
                    </tbody>
                </table>
            </div>

            <div id="eventDetails"></div>
        </div>

        <!-- LOGIN / SIGNUP -->
        <div id="loginSection" class="hidden section">
            <div class="login-signup">
                <div class="login-column">
                    <h2>Login</h2>
                    <div class="login-tagline">Access your favorites and wallet.</div>
                    <div class="field">
                        <span class="label" style="color:#aeb7ff;">Username</span><br>
                        <input id="liUsername" type="text">
                    </div>
                    <div class="field">
                        <span class="label" style="color:#aeb7ff;">Password</span><br>
                        <input id="liPassword" type="password">
                    </div>
                    <button class="btn" onclick="doLogin()">
                        <span class="btn-icon">➡</span> Submit
                    </button>
                </div>
                <div class="login-column">
                    <h2>Sign Up</h2>
                    <div class="login-tagline">Create an account to save events and manage your tickets.</div>
                    <div class="field">
                        <span class="label" style="color:#aeb7ff;">Email</span><br>
                        <input id="suEmail" type="email">
                    </div>
                    <div class="field">
                        <span class="label" style="color:#aeb7ff;">Username</span><br>
                        <input id="suUsername" type="text">
                    </div>
                    <div class="field">
                        <span class="label" style="color:#aeb7ff;">Password</span><br>
                        <input id="suPassword" type="password">
                    </div>
                    <div class="field">
                        <span class="label" style="color:#aeb7ff;">Confirm Password</span><br>
                        <input id="suPassword2" type="password">
                    </div>
                    <button class="btn" onclick="doSignup()">
                        <span class="btn-icon">✨</span> Submit
                    </button>
                </div>
            </div>
        </div>

        <!-- FAVORITES -->
        <div id="favoritesSection" class="hidden section">
            <h2>My Favorites</h2>
            <div id="favoritesList"></div>
        </div>

        <!-- WALLET -->
        <div id="walletSection" class="hidden section">
            <h2>My Wallet</h2>
            <div class="wallet-summary">
                <div class="wallet-summary-row">
                    <span class="label">Cash Balance:</span>
                    &nbsp;$<span id="cashBalance">0.00</span>
                </div>
                <div class="wallet-summary-row">
                    <span class="label">Total Account Value:</span>
                    &nbsp;$<span id="totalAccountValue">0.00</span>
                </div>
            </div>
            <div id="walletPositions"></div>
        </div>

    </div>
</div>
</body>
</html>




