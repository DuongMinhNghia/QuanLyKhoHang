package controller;

import dao.HangHoaDAO;
import model.HangHoa;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/LoadDanhSachKhoServlet")
public class LoadDanhSachKhoServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Setup tiếng Việt để không bị lỗi font
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // 1. Gọi DAO lấy danh sách hàng hóa từ SQL
        HangHoaDAO dao = new HangHoaDAO();
        List<HangHoa> listHH = dao.getAllHangHoa();

        // 2. Gắn danh sách vừa lấy được vào request để gửi sang trang JSP
        request.setAttribute("danhSachHH", listHH);

        // 3. Chuyển hướng người dùng sang trang giao diện
        request.getRequestDispatcher("quanlyhanghoa.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}