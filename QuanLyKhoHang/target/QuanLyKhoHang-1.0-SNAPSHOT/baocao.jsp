<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.taikhoan" %>
<%@ page import="model.PhieuNhapDTO" %>
<%@ page import="model.PhieuXuatDTO" %>
<%@ page import="model.KiemKeDTO" %>
<%
    taikhoan acc = (taikhoan) session.getAttribute("account");
    if(acc == null) { response.sendRedirect("login.jsp"); return; }
    
    String loai = (String) request.getAttribute("loaiHienTai");
    String filter = (String) request.getAttribute("filterHienTai");

    // Khởi tạo biến đếm và biến chuỗi cho biểu đồ
    int countDaDuyet = 0;
    int countChoDuyet = 0;
    StringBuilder chartLabels = new StringBuilder("[");
    StringBuilder chartData = new StringBuilder("[");
    StringBuilder chartColors = new StringBuilder("[");
    boolean firstChart = true;
    
 // 2. LOGIC PHÂN QUYỀN
    String role = acc.getVaiTro() != null ? acc.getVaiTro() : "";
  
    boolean showHangHoa      = role.equalsIgnoreCase("Thủ kho") || role.equalsIgnoreCase("Trưởng kho") || role.equalsIgnoreCase("Giám đốc");
    // 1. Chỉ hiện Menu Nhập/Xuất bên trái cho Trưởng kho & Giám đốc
    boolean showMenuNhapXuat = role.equalsIgnoreCase("Trưởng kho") || role.equalsIgnoreCase("Giám đốc");
    // 2. Cho phép Thủ kho, Trưởng kho, Giám đốc thấy Nút bấm lập phiếu
    boolean showBtnLapPhieu  = role.equalsIgnoreCase("Thủ kho") || role.equalsIgnoreCase("Trưởng kho") || role.equalsIgnoreCase("Giám đốc");
    
    boolean showBaoCao       = role.equalsIgnoreCase("Thủ kho") || role.equalsIgnoreCase("Trưởng kho") || role.equalsIgnoreCase("Giám đốc") || role.equalsIgnoreCase("Admin");
    boolean showLichSu       = role.equalsIgnoreCase("Thủ kho") || role.equalsIgnoreCase("Trưởng kho") || role.equalsIgnoreCase("Giám đốc") || role.equalsIgnoreCase("Admin");
    boolean showTaiKhoan     = role.equalsIgnoreCase("Admin");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Báo Cáo Thống Kê - WMS</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { display: flex; background-color: #f5f6f8; height: 100vh; overflow: hidden; }
        .sidebar { width: 250px; background-color: #ffffff; border-right: 1px solid #e0e0e0; padding: 20px 0; }
        .sidebar-logo { font-size: 20px; font-weight: bold; color: #333; padding: 0 20px 20px; border-bottom: 1px solid #eee; margin-bottom: 10px; }
        .menu-title { font-size: 12px; color: #888; font-weight: bold; padding: 10px 20px; text-transform: uppercase; }
        .menu-item { padding: 12px 20px; color: #555; text-decoration: none; display: block; font-weight: 500; }
        .menu-item.active { background-color: #e6efff; color: #0056b3; border-right: 3px solid #0056b3; }
        .main-content { flex: 1; display: flex; flex-direction: column; overflow-y: auto; }
        .topbar { height: 60px; background-color: #ffffff; border-bottom: 1px solid #e0e0e0; display: flex; justify-content: space-between; align-items: center; padding: 0 30px; }
        .content-body { padding: 30px; }
        .card { background-color: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); padding: 25px; margin-bottom: 20px; }
        
        .filter-container { display: flex; gap: 20px; align-items: center; background-color: #e9ecef; padding: 15px; border-radius: 5px; margin-bottom: 20px;}
        select, button { padding: 8px 12px; border-radius: 4px; border: 1px solid #ccc; outline: none; }
        button { background-color: #0056b3; color: white; border: none; cursor: pointer; font-weight: bold;}
        
        /* THIẾT KẾ GRIDVIEW CUỘN MƯỢT MÀ */
        .table-wrapper { max-height: 400px; overflow-y: auto; border: 1px solid #eee; border-radius: 4px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; border-right: 1px solid #eee; }
        th { background-color: #f8f9fa; color: #333; font-weight: bold; position: sticky; top: 0; z-index: 10; box-shadow: 0 2px 2px -1px rgba(0,0,0,0.1); }
        
        .badge-green { background-color: #d4edda; color: #155724; padding: 4px 8px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .badge-yellow { background-color: #fff3cd; color: #856404; padding: 4px 8px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .badge-red { background-color: #f8d7da; color: #721c24; padding: 4px 8px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        
        /* BOX THỐNG KÊ PHÍA DƯỚI */
        .summary-box { display: flex; gap: 30px; margin-top: 20px; padding: 15px 20px; background-color: #f8f9fa; border-left: 5px solid #0056b3; border-radius: 5px; }
        .summary-item { font-size: 16px; font-weight: bold; color: #333; }
        .text-green { color: #2ecc71; font-size: 20px;}
        .text-yellow { color: #f39c12; font-size: 20px;}
    </style>
</head>
<body>

    <!-- ================= SIDEBAR ================= -->
       <div class="sidebar">
        <div class="sidebar-logo">📦 Minh Phát</div>
        <div class="menu-title">MENU CHÍNH</div>
        
        <a href="home.jsp" class="menu-item">Dashboard</a>
        
       <% if(showMenuNhapXuat) { %>
            <a href="LapPhieuNhapServlet" class="menu-item">Lập phiếu nhập kho</a>
            <a href="LapPhieuXuatServlet" class="menu-item">Lập phiếu Xuất kho</a>
            <a href="#" class="menu-item">Nhà cung cấp</a>
        <% } %>

        <% if(showHangHoa) { %>
            <a href="LoadDanhSachKhoServlet" class="menu-item ">Quản lý hàng hóa</a>
            <a href="KiemKeServlet" class="menu-item">Kiểm kê</a>
        <% } %>
        
        <% if(showBaoCao) { %>
            <a href="BaoCaoServlet" class="menu-item active">Báo cáo</a>
        <% } %>
        
        <% if(showLichSu) { %>
            <a href="LichSuServlet" class="menu-item">Lịch sử tồn kho</a>
        <% } %>

        <% if(showTaiKhoan) { %>
            <a href="#" class="menu-item">Quản lý tài khoản</a>
        <% } %>
    </div>

    <div class="main-content">
        <div class="topbar">
            <div style="font-size: 18px; font-weight: bold;">Trung Tâm Báo Cáo Thống Kê</div>
            <div><%= acc.getHoTen() %> | <%= acc.getVaiTro() %></div>
        </div>

        <div class="content-body">
            <div class="card">
                <form action="BaoCaoServlet" method="GET" class="filter-container">
                    <div>
                        <label style="font-weight: bold; margin-right: 10px;">📋 Loại Báo Cáo:</label>
                        <select name="loai" id="loaiBaoCao" onchange="doiBoLoc()">
                            <option value="nhapkho" <%= "nhapkho".equals(loai) ? "selected" : "" %>>Báo Cáo Nhập Kho</option>
                            <option value="xuatkho" <%= "xuatkho".equals(loai) ? "selected" : "" %>>Báo Cáo Xuất Kho</option>
                            <option value="kiemke" <%= "kiemke".equals(loai) ? "selected" : "" %>>Báo Cáo Kiểm Kê</option>
                        </select>
                    </div>
                    <div>
                        <label style="font-weight: bold; margin-right: 10px;">🔍 Bộ Lọc:</label>
                        <select name="filter" id="filterBaoCao"></select>
                    </div>
                    <button type="submit">Lọc Dữ Liệu</button>
                </form>

                <div class="table-wrapper">
                    <table>
                        <% if("nhapkho".equals(loai) || "xuatkho".equals(loai)) { %>
                            <thead>
                                <tr>
                                    <th>Mã Phiếu</th>
                                    <th>Ngày Lập</th>
                                    <th><%= "nhapkho".equals(loai) ? "Nhà Cung Cấp" : "Sản Phẩm" %></th>
                                    <th>Số Lượng</th>
                                    <th>Tổng Tiền</th>
                                    <th>Trạng Thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    List<?> danhSach = (List<?>) request.getAttribute("danhSach");
                                    if(danhSach != null && !danhSach.isEmpty()) {
                                        java.text.DecimalFormat df = new java.text.DecimalFormat("#,### đ");
                                        for(Object obj : danhSach) {
                                            if (obj instanceof PhieuNhapDTO) {
                                                PhieuNhapDTO pn = (PhieuNhapDTO) obj;
                                                // Đếm số lượng Duyệt / Chờ duyệt
                                                if(pn.getMaNguoiDuyet() != null) countDaDuyet++; else countChoDuyet++;
                                %>
                                <tr>
                                    <td><b><%= pn.getMaPhieu() %></b></td>
                                    <td><%= pn.getNgayLap() %></td>
                                    <td><%= pn.getTenNCC() %> <br> <i>(<%= pn.getTenHang() %>)</i></td>
                                    <td><%= pn.getSoLuong() %></td>
                                    <td><%= df.format(pn.getDonGia() * pn.getSoLuong()) %></td>
                                    <td><%= pn.getMaNguoiDuyet() == null ? "<span class='badge-yellow'>⏳ Chờ duyệt</span>" : "<span class='badge-green'>✅ Đã duyệt</span>" %></td>
                                </tr>
                                <%          } else if (obj instanceof PhieuXuatDTO) {
                                                PhieuXuatDTO px = (PhieuXuatDTO) obj;
                                                if(px.getMaNguoiDuyet() != null) countDaDuyet++; else countChoDuyet++;
                                %>
                                <tr>
                                    <td><b><%= px.getMaPhieu() %></b></td>
                                    <td><%= px.getNgayLap() %></td>
                                    <td><%= px.getTenHang() %></td>
                                    <td><%= px.getSoLuong() %></td>
                                    <td><%= df.format(px.getDonGia() * px.getSoLuong()) %></td>
                                    <td><%= px.getMaNguoiDuyet() == null ? "<span class='badge-yellow'>⏳ Chờ duyệt</span>" : "<span class='badge-green'>✅ Đã duyệt</span>" %></td>
                                </tr>
                                <% 
                                            }
                                        }
                                    } else { out.print("<tr><td colspan='6' style='text-align:center;'>Không có dữ liệu phù hợp.</td></tr>"); }
                                %>
                            </tbody>

                        <% } else if("kiemke".equals(loai)) { %>
                            <thead>
                                <tr>
                                    <th>Mã Phiếu</th>
                                    <th>Ngày Kiểm</th>
                                    <th>Sản Phẩm</th>
                                    <th>Lý Thuyết</th>
                                    <th>Thực Tế</th>
                                    <th>Độ Lệch</th>
                                    <th>Tình Trạng / Ghi Chú</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    List<KiemKeDTO> listKK = (List<KiemKeDTO>) request.getAttribute("danhSach");
                                    if(listKK != null && !listKK.isEmpty()) {
                                        for(KiemKeDTO kk : listKK) {
                                            // Lấy dữ liệu cho biểu đồ (Chỉ lấy món có chênh lệch)
                                            if (kk.getChenhLech() != 0) {
                                                if (!firstChart) { chartLabels.append(","); chartData.append(","); chartColors.append(","); }
                                                chartLabels.append("'").append(kk.getTenHang()).append(" (").append(kk.getMaKiemKe()).append(")'");
                                                chartData.append(kk.getChenhLech());
                                                chartColors.append(kk.getChenhLech() > 0 ? "'#2ecc71'" : "'#e74c3c'"); // Dư = Xanh, Thiếu = Đỏ
                                                firstChart = false;
                                            }
                                %>
                                <tr>
                                    <td><b><%= kk.getMaKiemKe() %></b></td>
                                    <td><%= kk.getNgayKiem() %></td>
                                    <td><%= kk.getTenHang() %></td>
                                    <td><%= kk.getLyThuyet() %></td>
                                    <td><b><%= kk.getThucTe() %></b></td>
                                    <td>
                                        <% if(kk.getChenhLech() == 0) { out.print("<span style='color:green; font-weight:bold;'>0</span>"); }
                                           else { out.print("<span style='color:red; font-weight:bold;'>" + kk.getChenhLech() + "</span>"); } %>
                                    </td>
                                    <td>
                                        <% if(kk.getChenhLech() == 0) { out.print("<span class='badge-green'>✅ Bình thường</span>"); }
                                           else { out.print("<span class='badge-red'>⚠️ Đã điều chỉnh lệch</span> <br><i>(" + kk.getNguyenNhan() + ")</i>"); } %>
                                    </td>
                                </tr>
                                <%      }
                                    } else { out.print("<tr><td colspan='7' style='text-align:center;'>Không có dữ liệu phù hợp.</td></tr>"); }
                                %>
                            </tbody>
                        <% } %>
                    </table>
                </div>

                <% 
                   // Đóng ngoặc chuỗi dữ liệu biểu đồ
                   chartLabels.append("]"); chartData.append("]"); chartColors.append("]");
                %>

                <% if("nhapkho".equals(loai) || "xuatkho".equals(loai)) { %>
                    <div class="summary-box">
                        <div class="summary-item">✅ Tổng số phiếu Đã Duyệt: <span class="text-green"><%= countDaDuyet %></span></div>
                        <div class="summary-item">⏳ Tổng số phiếu Đang Chờ: <span class="text-yellow"><%= countChoDuyet %></span></div>
                    </div>
                <% } else if("kiemke".equals(loai)) { %>
                    <div style="margin-top: 30px; border-top: 2px dashed #eee; padding-top: 20px;">
                        <h3 style="margin-bottom: 15px; color: #333;">📊 Phân tích độ lệch hàng hóa (Dư / Thiếu)</h3>
                        <canvas id="chenhLechChart" height="80"></canvas>
                    </div>
                    
                    <script>
                        window.addEventListener('load', function() {
                            const ctx = document.getElementById('chenhLechChart').getContext('2d');
                            const dataLech = <%= chartData.toString() %>;
                            
                            if (dataLech.length === 0) {
                                document.getElementById('chenhLechChart').parentElement.innerHTML += "<p style='color:green; font-weight:bold;'>Tất cả các phiếu kiểm kê đều khớp 100%, không có sai lệch!</p>";
                                document.getElementById('chenhLechChart').style.display = 'none';
                                return;
                            }

                            new Chart(ctx, {
                                type: 'bar',
                                data: {
                                    labels: <%= chartLabels.toString() %>,
                                    datasets: [{
                                        label: 'Số lượng chênh lệch',
                                        data: dataLech,
                                        backgroundColor: <%= chartColors.toString() %>, // Xanh lá nếu > 0, Đỏ nếu < 0
                                        borderRadius: 4
                                    }]
                                },
                                options: {
                                    responsive: true,
                                    plugins: { legend: { display: false } },
                                    scales: { y: { title: { display: true, text: 'Số lượng (Dư > 0, Thiếu < 0)' } } }
                                }
                            });
                        });
                    </script>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        var boLocHienTai = "<%= filter %>";

        function doiBoLoc() {
            var loai = document.getElementById("loaiBaoCao").value;
            var selectFilter = document.getElementById("filterBaoCao");
            selectFilter.innerHTML = ""; 

            if (loai === "nhapkho" || loai === "xuatkho") {
                selectFilter.options.add(new Option("Tất cả trạng thái", "all"));
                selectFilter.options.add(new Option("Chỉ xem phiếu ĐÃ DUYỆT", "daduyet"));
                selectFilter.options.add(new Option("Chỉ xem phiếu CHỜ DUYỆT", "choduyet"));
            } else if (loai === "kiemke") {
                selectFilter.options.add(new Option("Tất cả phiếu kiểm kê", "all"));
                selectFilter.options.add(new Option("⚠️ Có sai lệch (Đã điều chỉnh)", "lech"));
                selectFilter.options.add(new Option("✅ Bình thường (Khớp số lượng)", "khop"));
            }

            for (var i = 0; i < selectFilter.options.length; i++) {
                if (selectFilter.options[i].value === boLocHienTai) {
                    selectFilter.selectedIndex = i;
                    break;
                }
            }
        }
        window.onload = doiBoLoc;
    </script>
</body>
</html>