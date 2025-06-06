# Hotel Booking Performance Analysis
![image](https://github.com/user-attachments/assets/652125fe-3648-40c0-95c7-c56d87bf88d2)

1. Project Overview
This project provides a comprehensive analysis of hotel booking data to uncover key insights into business performance. The primary goal is to transform raw booking data into actionable business intelligence, enabling stakeholders to make data-driven decisions to optimize revenue, improve guest experience, and reduce cancellations.

The analysis focuses on three core areas:

Booking Performance: Analyzing key metrics such as occupancy rates, booking volumes, and seasonality.

Revenue Streams: Evaluating revenue generated from both room bookings and ancillary services.

Cancellation Rates: Identifying patterns and drivers behind booking cancellations to mitigate revenue loss.

2. Tools & Technologies

- Database: Microsoft SQL Server

- Data Analysis & Querying: SQL

- Data Visualization & Dashboarding: Microsoft Power BI

3. Data Processing & Analysis (SQL)
The initial phase involved setting up a relational database in SQL Server to store, clean, and query the dataset. This ensures data integrity and enables efficient analysis.

3.1. Database Setup
A database named hotel_analysis was created. The dataset was imported and structured into six main tables: bookings_senior, customers_senior, rooms_senior, services_senior, payments_senior, and service_usage_senior.

3.2. Data Structuring and Integrity
Foreign key constraints were established to create a relational model, ensuring data consistency across the tables.

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

3.3. SQL Query for Analysis
A series of T-SQL queries were executed to explore the data and extract key metrics. The queries are categorized by the area of analysis.

I. Booking Performance Analysis

Total Confirmed Room Nights: Measures the total number of nights guests have stayed for confirmed bookings.

SELECT
    SUM(DATEDIFF(day, b.check_in, b.check_out)) AS total_nights_booked_room
FROM bookings_senior AS b
WHERE b.status = 'Confirmed';

![image](https://github.com/user-attachments/assets/96334354-8b9f-42be-ba8d-7647877b7d8c)

Average Length of Stay: Calculates the average duration of a guest's stay.

SELECT
    AVG(DATEDIFF(day, b.check_in, b.check_out)) AS avg_length_of_stay
FROM bookings_senior AS b
WHERE b.status = 'Confirmed';

![image](https://github.com/user-attachments/assets/6c78e0a5-dfda-4d3f-8784-749fed2c3d81)

Peak and Off-Peak Seasons (by Month): Identifies high-demand and low-demand periods throughout the year.

SELECT
    YEAR(b.check_in) AS year,
    MONTH(b.check_in) AS month,
    SUM(DATEDIFF(day, b.check_in, b.check_out)) AS total_nights_booked
FROM bookings_senior AS b
WHERE b.status = 'Confirmed'
GROUP BY YEAR(b.check_in), MONTH(b.check_in)
ORDER BY total_nights_booked DESC;

![image](https://github.com/user-attachments/assets/64b05bae-dc8b-4ff1-9e94-0416bb359c14)

II. Revenue from Rooms & Services

Total Room Revenue: Calculates the total revenue generated from room bookings.

SELECT
    SUM(DATEDIFF(day, b.check_in, b.check_out) * r.price_per_night) AS total_room_revenue
FROM bookings_senior AS b JOIN rooms_senior AS r ON b.room_id = r.room_id
WHERE b.status = 'Confirmed';

![image](https://github.com/user-attachments/assets/5a1b3236-fa3a-48ed-9a97-45097b86f1e9)

Total Service Revenue: Calculates the total revenue from ancillary services.

SELECT
    SUM(CAST(su.quantity AS INT) * CAST(s.price AS DECIMAL(10, 0))) AS total_service_revenue
FROM service_usage_senior AS su ...
WHERE b.status = 'Confirmed';

![image](https://github.com/user-attachments/assets/c0d243e7-0870-4620-96f4-7ae87af967a3)

Top 10 Revenue-Generating Rooms: Identifies the most profitable individual rooms.

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

Overall Cancellation Rate: Calculates the percentage of total bookings that were canceled.

SELECT
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS cancelled_bookings_rate
FROM bookings_senior;

![image](https://github.com/user-attachments/assets/d59103ae-56da-4330-9e09-ee9c13101f09)

Cancellation Rate by Room Type: Analyzes which room types have the highest cancellation rates.

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

IV. Customer Return Rate Analysis

Customer Return Rate: Calculates the percentage of unique customers who have made more than one booking.

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

4. Power BI Dashboards & Key Insights
The processed data and SQL queries were used to build three interactive dashboards in Power BI, each designed to answer specific business questions.

Dashboard 1: Hotel Booking Performance Overview
![image](https://github.com/user-attachments/assets/7789a370-8ef8-4c65-82e4-a121c0ade819)

This dashboard provides a high-level, 360-degree view of the hotel's overall health.

Key Insights:

Strong Performance in High-End Segment: The Deluxe and Presidential rooms are the primary revenue drivers, indicating a strong appeal to premium customers.

Clear Seasonality: The business experiences distinct peak seasons in the summer (May-July) and during the year-end holidays (Oct-Dec). This allows for strategic planning around dynamic pricing and marketing campaigns.

The Pricing Paradox: A critical insight reveals that the Presidential room, despite being a higher-tier category, has a lower average revenue per booking than the Deluxe room. This suggests a potential pricing strategy or product positioning issue that needs to be addressed.

Untapped Service Revenue: Room revenue constitutes a dominant 84% of total revenue, while service revenue only contributes 16%. This highlights a significant, untapped opportunity to increase overall revenue by promoting and upselling ancillary services (F&B, spa, tours, etc.).

Dashboard 2: Rooms & Services Revenue Performance
![image](https://github.com/user-attachments/assets/21facd49-5f6f-4b0f-96f9-fcefc9e24e36)

This dashboard dives deeper into what drives revenue and how different assets are performing.

Key Insights:

ADR (Average Daily Rate) Discrepancy: Analysis shows that the ADR for Deluxe rooms is currently higher than for Presidential rooms, confirming the pricing paradox found in the overview. This data supports a strategic review of the room rate structure.

Most Popular Services: The dashboard identifies the top revenue-generating services, allowing management to focus marketing efforts on popular offerings or create bundled packages (e.g., room + spa combo).

Underperforming Assets: By comparing revenue, occupancy, and ADR, the dashboard helps identify underperforming room types (e.g., Standard rooms) that may require promotional activities or a re-evaluation of their market position.

Dashboard 3: Cancellation Analysis
![image](https://github.com/user-attachments/assets/d1d30394-2748-4148-b73d-f2dba712d2c9)

This dashboard is dedicated to understanding the "why" behind cancellations to mitigate revenue loss.

Key Insights:

Concerning Cancellation Rate: The overall cancellation rate stands at 34%. While within some industry ranges, it is on the higher end and represents a significant area for improvement.

Cancellation "Hotspots": The interactive dashboard allows for filtering to find patterns. For example, analysis may reveal that a specific room type, booking channel, or bookings made far in advance (high lead time) have a disproportionately high cancellation rate.

Actionable Mitigation Strategies: These insights lead to concrete strategies, such as:

Implementing stricter cancellation policies or non-refundable rates for high-risk bookings.

Launching pre-arrival engagement campaigns (e.g., emails with hotel service offers) to strengthen the customer's commitment.

Ensuring room descriptions and photos are accurate to manage guest expectations.

5. Conclusion & Strategic Recommendations
This project successfully transformed raw data into actionable intelligence. The analysis revealed that while the hotel performs exceptionally well in the premium segment, there are clear strategic opportunities to:

Rectify the Pricing & Positioning Strategy: Address the "Presidential vs. Deluxe" paradox to ensure the hotel's branding is consistent with its pricing.

Exploit the Service Revenue "Goldmine": Shift from a "room-selling" to an "experience-selling" mindset by creating and promoting service bundles and upselling opportunities.

Proactively Reduce Cancellations: Implement data-driven cancellation policies and customer engagement strategies to secure more revenue.

By leveraging these insights, the hotel can significantly enhance its revenue, operational efficiency, and overall market position.
