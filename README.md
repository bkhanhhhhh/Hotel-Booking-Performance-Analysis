# Hotel Booking Performance Analysis
![image](https://github.com/user-attachments/assets/652125fe-3648-40c0-95c7-c56d87bf88d2)

## 1. 📊 Project Overview
This project provides a comprehensive analysis of hotel booking data to uncover key insights into business performance. The primary goal is to transform raw booking data into actionable business intelligence, enabling stakeholders to make data-driven decisions to:

✅ Optimize revenue
✅ Improve guest experience
✅ Reduce cancellations

Core areas of analysis:

Booking Performance: Analyzing occupancy rates, booking volumes, and seasonality.

Revenue Streams: Evaluating revenue from room bookings and ancillary services.

Cancellation Rates: Identifying patterns and drivers behind booking cancellations.

## 2. 🛠️ Tools & Technologies

- Database: Microsoft SQL Server

- Data Analysis & Querying: SQL

- Data Visualization & Dashboarding: Microsoft Power BI

## 3. 🗂️ Data Processing & Analysis (SQL)
### 3.1 Database Setup
- Database: hotel_analysis

- Main Tables:

bookings_senior

customers_senior

rooms_senior

services_senior

payments_senior

service_usage_senior

### 3.2 Data Integrity
Establishing foreign key constraints to ensure relational integrity:

-- Adding foreign key from bookings_senior to customers_senior
ALTER TABLE bookings_senior
ADD CONSTRAINT fk_bookings_customer
    FOREIGN KEY (customer_id)
    REFERENCES customers_senior(customer_id);

-- Adding foreign key from bookings_senior to rooms_senior
ALTER TABLE bookings_senior
ADD CONSTRAINT fk_bookings_room
    FOREIGN KEY (room_id)
    REFERENCES rooms_senior(room_id);

### 3.3 Key SQL Queries
I. Booking Performance
✅ Total Confirmed Room Nights

SELECT SUM(DATEDIFF(day, b.check_in, b.check_out)) AS total_nights_booked_room
FROM bookings_senior AS b
WHERE b.status = 'Confirmed';

![image](https://github.com/user-attachments/assets/96334354-8b9f-42be-ba8d-7647877b7d8c)

✅ Average Length of Stay

SELECT
    AVG(DATEDIFF(day, b.check_in, b.check_out)) AS avg_length_of_stay
FROM bookings_senior AS b
WHERE b.status = 'Confirmed';

![image](https://github.com/user-attachments/assets/6c78e0a5-dfda-4d3f-8784-749fed2c3d81)

✅ Peak and Off-Peak Seasons

SELECT
    YEAR(b.check_in) AS year,
    MONTH(b.check_in) AS month,
    SUM(DATEDIFF(day, b.check_in, b.check_out)) AS total_nights_booked
FROM bookings_senior AS b
WHERE b.status = 'Confirmed'
GROUP BY YEAR(b.check_in), MONTH(b.check_in)
ORDER BY total_nights_booked DESC;

![image](https://github.com/user-attachments/assets/64b05bae-dc8b-4ff1-9e94-0416bb359c14)

II. Revenue Analysis
✅ Total Room Revenue

SELECT
    SUM(DATEDIFF(day, b.check_in, b.check_out) * r.price_per_night) AS total_room_revenue
FROM bookings_senior AS b JOIN rooms_senior AS r ON b.room_id = r.room_id
WHERE b.status = 'Confirmed';

![image](https://github.com/user-attachments/assets/5a1b3236-fa3a-48ed-9a97-45097b86f1e9)

✅ Total Service Revenue

SELECT
    SUM(CAST(su.quantity AS INT) * CAST(s.price AS DECIMAL(10, 0))) AS total_service_revenue
FROM service_usage_senior AS su ...
WHERE b.status = 'Confirmed';

![image](https://github.com/user-attachments/assets/c0d243e7-0870-4620-96f4-7ae87af967a3)

✅ Top 10 Revenue-Generating Rooms

SELECT TOP 10
    r.room_id,
    r.room_type,
    SUM(DATEDIFF(day, b.check_in, b.check_out) * r.price_per_night) AS total_revenue
FROM bookings_senior AS b
JOIN rooms_senior AS r ON b.room_id = r.room_id
WHERE b.status = 'Confirmed'
GROUP BY r.room_id, r.room_type
ORDER BY total_revenue DESC;

![image](https://github.com/user-attachments/assets/1014bfe4-4a6d-44a3-9f94-ab11729e0c0b)

III. Cancellation Rate Analysis
✅ Overall Cancellation Rate

SELECT
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS cancelled_bookings_rate
FROM bookings_senior;

![image](https://github.com/user-attachments/assets/d59103ae-56da-4330-9e09-ee9c13101f09)

✅ Cancellation Rate by Room Type

SELECT
    r.room_type,
    COUNT (b.booking_id) AS total_bookings_room_type,
    SUM(CASE WHEN b.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_bookings_room_type,
    SUM(CASE WHEN b.status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(b.booking_id) AS cancelled_rate_room_type
FROM bookings_senior AS b
JOIN rooms_senior AS r ON b.room_id = r.room_id
GROUP BY r.room_type
ORDER BY cancelled_rate_room_type DESC;

![image](https://github.com/user-attachments/assets/3dae5c5b-1d7c-4278-a2ab-e5cb914a2cea)

IV. Customer Return Rate
✅ Return Rate Analysis

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

![image](https://github.com/user-attachments/assets/960b05c1-f97d-45ce-ab83-980a21d1ba95)

## 4. 📈 Power BI Dashboards & Key Insights
### Dashboard 1: Hotel Booking Performance Overview
![image](https://github.com/user-attachments/assets/7789a370-8ef8-4c65-82e4-a121c0ade819)

Key Insights:

- Strong Performance: Deluxe and Presidential rooms drive the majority of revenue.

- Clear Seasonality: Peaks in May-July and October-December.

- Pricing Paradox: Presidential room yields lower revenue per booking than Deluxe room.

- Untapped Service Revenue: Services contribute only 16% of total revenue.

### Dashboard 2: Rooms & Services Revenue Performance
![image](https://github.com/user-attachments/assets/21facd49-5f6f-4b0f-96f9-fcefc9e24e36)

Key Insights:

- ADR Discrepancy: Deluxe rooms have a higher ADR than Presidential rooms.

- Popular Services: Highlights top-selling services for marketing and bundling.

- Underperforming Assets: Standard rooms underperform in revenue and occupancy.

### Dashboard 3: Cancellation Analysis
![image](https://github.com/user-attachments/assets/d1d30394-2748-4148-b73d-f2dba712d2c9)

Key Insights:

- High Cancellation Rate: 34% overall, indicating significant revenue risk.

- Cancellation Hotspots: Identifies patterns by room type, lead time, and channel.

- Mitigation Strategies: Stricter policies, pre-arrival engagement, accurate marketing.

## 5. 📝 Conclusion & Recommendations
✅ Fix Pricing & Positioning: Address the Presidential vs. Deluxe pricing paradox.
✅ Unlock Service Revenue: Focus on upselling and bundling services.
✅ Reduce Cancellations: Data-driven policies and engagement strategies.
