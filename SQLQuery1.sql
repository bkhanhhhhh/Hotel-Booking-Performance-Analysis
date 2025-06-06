USE hotel_analysis;

-- Kiểm tra cấu trúc bảng
SELECT TOP 10 * FROM bookings_senior;
SELECT TOP 10 * FROM customers_senior;
SELECT TOP 10 * FROM rooms_senior;
SELECT TOP 10 * FROM services_senior;
SELECT TOP 10 * FROM payments_senior;
SELECT TOP 10 * FROM service_usage_senior;

-- Tạo khóa ngoại
ALTER TABLE bookings_senior
ADD CONSTRAINT fk_bookings_customer
    FOREIGN KEY (customer_id)
    REFERENCES customers_senior(customer_id);

ALTER TABLE bookings_senior
ADD CONSTRAINT fk_bookings_room
    FOREIGN KEY (room_id)
    REFERENCES rooms_senior(room_id);

ALTER TABLE payments_senior
ADD CONSTRAINT fk_payments_booking
    FOREIGN KEY (booking_id)
    REFERENCES bookings_senior(booking_id);

ALTER TABLE service_usage_senior
ADD CONSTRAINT fk_usage_booking
    FOREIGN KEY (booking_id)
    REFERENCES bookings_senior(booking_id);

ALTER TABLE service_usage_senior
ADD CONSTRAINT fk_usage_service
    FOREIGN KEY (service_id)
    REFERENCES services_senior(service_id);


-- I. HIỆU SUẤT ĐẶT PHÒNG

-- Tổng số đêm phòng đã đặt
SELECT
    SUM(DATEDIFF(day, b.check_in, b.check_out)) AS total_nights_booked_room
FROM bookings_senior AS b
WHERE b.status = 'Confirmed';

-- Số đêm phòng đã đặt theo loại phòng
SELECT
    r.room_type,
    SUM(DATEDIFF(day, b.check_in, b.check_out)) AS booked_room_type
FROM bookings_senior AS b
JOIN rooms_senior AS r ON b.room_id = r.room_id
WHERE b.status = 'Confirmed'
GROUP BY r.room_type
ORDER BY booked_room_type DESC;

-- Độ dài trung bình kỳ lưu trú
SELECT
    AVG(DATEDIFF(day, b.check_in, b.check_out)) AS avg_length_of_stay
FROM bookings_senior AS b
WHERE b.status = 'Confirmed';

-- Xác định tháng cao điểm và thấp điểm
SELECT
    YEAR(b.check_in) AS year,
    MONTH(b.check_in) AS month,
    SUM(DATEDIFF(day, b.check_in, b.check_out)) AS total_nights_booked
FROM bookings_senior AS b
WHERE b.status = 'Confirmed'
GROUP BY YEAR(b.check_in), MONTH(b.check_in)
ORDER BY total_nights_booked DESC;

-- Theo quý
SELECT
    YEAR(b.check_in) AS year,
    DATEPART(QUARTER, b.check_in) AS quarter,
    SUM(DATEDIFF(day, b.check_in, b.check_out)) AS total_nights_booked
FROM bookings_senior AS b
WHERE b.status = 'Confirmed'
GROUP BY YEAR(b.check_in), DATEPART(QUARTER, b.check_in)
ORDER BY total_nights_booked DESC;

--  II. DOANH THU TỪ PHÒNG VÀ DỊCH VỤ

-- Tổng doanh thu tất cả các phòng
SELECT
    SUM(DATEDIFF(day, b.check_in, b.check_out) * r.price_per_night) AS total_room_revenue
FROM bookings_senior AS b
JOIN rooms_senior AS r ON b.room_id = r.room_id
WHERE b.status = 'Confirmed';

-- Tổng doanh thu tất cả dịch vụ
SELECT
    SUM(CAST(su.quantity AS INT) * CAST(s.price AS DECIMAL(10, 0))) AS total_service_revenue
FROM service_usage_senior AS su
JOIN services_senior AS s ON su.service_id = s.service_id
JOIN bookings_senior AS b ON su.booking_id = b.booking_id
WHERE b.status = 'Confirmed';

-- Phòng có doanh thu cao nhất
SELECT TOP 10
    r.room_id,
    r.room_type,
    SUM(DATEDIFF(day, b.check_in, b.check_out) * r.price_per_night) AS total_revenue
FROM bookings_senior AS b
JOIN rooms_senior AS r ON b.room_id = r.room_id
WHERE b.status = 'Confirmed'
GROUP BY r.room_id, r.room_type
ORDER BY total_revenue DESC;

-- Loại phòng có doanh thu cao nhất
SELECT
    r.room_type,
    SUM(DATEDIFF(day, b.check_in, b.check_out) * r.price_per_night) AS total_revenue_room_type
FROM bookings_senior AS b
JOIN rooms_senior AS r ON b.room_id = r.room_id
WHERE b.status = 'Confirmed'
GROUP BY r.room_type
ORDER BY total_revenue_room_type DESC;

-- Doanh thu theo từng dịch vụ
SELECT
    s.service_name,
    SUM(CAST(su.quantity AS INT) * CAST(s.price AS DECIMAL(10, 0))) AS revenue_per_service
FROM service_usage_senior AS su
JOIN services_senior AS s ON su.service_id = s.service_id
JOIN bookings_senior AS b ON su.booking_id = b.booking_id
WHERE b.status = 'Confirmed'
GROUP BY s.service_name
ORDER BY revenue_per_service DESC;

-- III. TỶ LỆ HỦY ĐẶT PHÒNG

-- Tổng số lượt đặt phòng và số lượt hủy
SELECT
    COUNT (*) AS total_bookings,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_bookings
FROM bookings_senior;

-- Tỷ lệ hủy đặt phòng
SELECT
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS cancelled_bookings_rate
FROM bookings_senior;

-- Tỷ lệ hủy theo loại phòng
SELECT
    r.room_type,
    COUNT (b.booking_id) AS total_bookings_room_type,
    SUM(CASE WHEN b.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_bookings_room_type,
    SUM(CASE WHEN b.status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(b.booking_id) AS cancelled_rate_room_type
FROM bookings_senior AS b
JOIN rooms_senior AS r ON b.room_id = r.room_id
GROUP BY r.room_type
ORDER BY cancelled_rate_room_type DESC;

-- Tỷ lệ hủy theo tháng
SELECT 
    FORMAT(check_in, 'yyyy-MM') AS bookings_month,
    COUNT (*) AS total_bookings_in_month,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_bookings_in_month,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) AS cancelled_rate_in_month
FROM bookings_senior
GROUP BY FORMAT(check_in, 'yyyy-MM')
ORDER BY bookings_month;

-- IV. TỶ LỆ KHÁCH HÀNG QUAY LẠI

-- Tìm khách hàng và số lần đặt phòng của họ
SELECT
    customer_id,
    COUNT (booking_id) AS number_of_bookings
FROM bookings_senior
WHERE status = 'Confirmed'
GROUP BY customer_id
ORDER BY number_of_bookings DESC;

-- Số lượng khách hàng quay lại và tổng số khách hàng unique
SELECT COUNT(customer_id) AS total_unique_customers
FROM bookings_senior
WHERE status = 'Confirmed';

SELECT COUNT(customer_id) AS returning_customers
FROM (
    SELECT customer_id
    FROM bookings_senior
    WHERE status = 'Confirmed'
    GROUP BY customer_id
    HAVING COUNT(booking_id) > 1
) AS returning_customers_count;

-- Tỷ lệ khách hàng quay lại
SELECT 
    COUNT(customer_id) AS total_unique_customers,
    COUNT(CASE WHEN bookings_count > 1 THEN customer_id END) AS returning_customers,
    COUNT(CASE WHEN bookings_count > 1 THEN customer_id END) * 100.0 / COUNT(customer_id) AS returning_rate
FROM (
    SELECT 
        customer_id,
        COUNT(booking_id) AS bookings_count
    FROM bookings_senior
    WHERE status = 'Confirmed'
    GROUP BY customer_id
) AS customer_statistics;