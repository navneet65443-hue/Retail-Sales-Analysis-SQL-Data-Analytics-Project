# 📊 Retail Sales Analysis | SQL Data Analytics Project

> **From raw transaction data to actionable business intelligence** — A comprehensive PostgreSQL analysis uncovering customer behavior, revenue trends, and growth opportunities in retail.

---

## 🎯 Project Overview

This project demonstrates **enterprise-grade SQL proficiency** by analyzing retail transactions across multiple categories, uncovering:
- **Revenue patterns** by customer demographics and time periods
- **Customer segmentation** strategies for targeted marketing
- **Growth trends** with month-over-month performance metrics
- **Operational insights** across sales channels and shifts

**Perfect for:** Data Analysts, Business Intelligence Engineers, Analytics Engineers

---

## 💼 Business Impact

### Key Questions Answered
| Question | Business Value | SQL Technique |
|----------|---|---|
| **Which categories drive the most revenue?** | Identifies high-margin product lines for inventory focus | GROUP BY + Aggregation |
| **Who are our top customers?** | Enables VIP retention and upsell programs | Window Functions (RANK) |
| **What's our month-over-month growth?** | Tracks business health and forecasting | LAG() + YoY Comparison |
| **How do demographics influence purchases?** | Powers personalized marketing campaigns | CTE + Demographic Analysis |
| **Which shifts generate peak sales?** | Optimizes staffing and inventory levels | CASE statements + Time Extraction |

---

## 🗂️ Database Schema

```sql
CREATE TABLE retail_sales (
    transaction_id INT PRIMARY KEY,
    sale_date DATE NOT NULL,
    sale_time TIME NOT NULL,
    customer_id INT NOT NULL,
    gender VARCHAR(15) NOT NULL,
    age INT NOT NULL,
    category VARCHAR(15) NOT NULL,
    quantity INT NOT NULL,
    price_per_unit FLOAT NOT NULL,
    cogs FLOAT NOT NULL,
    total_sale FLOAT NOT NULL
);
```
---

## 🔍 Analysis Highlights

### 1️⃣ **Revenue by Category** 
Understand which product lines drive profitability
```sql
SELECT 
    category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY net_sale DESC;
```
**Insight:** Identifies top-performing categories for strategic focus and inventory allocation.

---

### 2️⃣ **Customer Segmentation**
Identify your VIP customers for retention strategies
```sql
SELECT 
    customer_id,
    SUM(total_sale) AS total_customer_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_customer_sales DESC
LIMIT 5;
```
**Insight:** Top 5 customers likely represent 20-30% of revenue (Pareto principle). Enables targeted VIP programs.

---

### 3️⃣ **Month-over-Month Growth Analysis**
Track business momentum and identify seasonal patterns
```sql
WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS sale_year,
        EXTRACT(MONTH FROM sale_date) AS sale_month,
        SUM(total_sale) AS monthly_total_sales
    FROM retail_sales
    GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
)
SELECT 
    sale_year,
    sale_month,
    ROUND(monthly_total_sales::NUMERIC, 2) AS monthly_total_sales,
    ROUND(
        CASE 
            WHEN LAG(monthly_total_sales) OVER (ORDER BY sale_year, sale_month) IS NULL 
            THEN NULL
            ELSE ((monthly_total_sales - LAG(monthly_total_sales) OVER (ORDER BY sale_year, sale_month))
                  / LAG(monthly_total_sales) OVER (ORDER BY sale_year, sale_month)) * 100
        END, 2
    ) AS mom_growth_percentage
FROM monthly_sales
ORDER BY sale_year, sale_month;
```
**Insight:** Reveals seasonal peaks/troughs for demand forecasting and marketing calendar planning.

---

### 4️⃣ **Shift Performance Analysis**
Optimize operations by understanding peak sales periods
```sql
SELECT 
    CASE 
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) >= 12 AND EXTRACT(HOUR FROM sale_time) < 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(transaction_id) AS total_transactions
FROM retail_sales
GROUP BY shift;
```
**Insight:** Drives staffing optimization and peak inventory stocking decisions.

---

### 5️⃣ **Category & Gender Revenue Split**
Uncover demographic purchasing patterns
```sql
WITH category_gender_sales AS (
    SELECT 
        category,
        gender,
        SUM(total_sale) AS category_gender_sales
    FROM retail_sales
    GROUP BY category, gender
),
total_sales AS (
    SELECT SUM(total_sale) AS overall_total_sales FROM retail_sales
)
SELECT 
    cgs.category,
    cgs.gender,
    ROUND((cgs.category_gender_sales * 100.0 / ts.overall_total_sales)::NUMERIC, 2) AS percentage_of_total
FROM category_gender_sales cgs
CROSS JOIN total_sales ts
ORDER BY cgs.category, cgs.gender;
```
**Insight:** Enables targeted marketing campaigns and personalized product recommendations by demographic.

---

## 🛠️ SQL Skills Demonstrated

✅ **Data Cleaning:** NULL handling, data validation  
✅ **Aggregation:** GROUP BY, SUM, COUNT, AVG, DISTINCT  
✅ **Window Functions:** RANK(), LAG(), PARTITION BY  
✅ **CTEs (Common Table Expressions):** Multi-step analysis logic  
✅ **Date/Time Functions:** EXTRACT, date filtering  
✅ **Joins & Set Operations:** CROSS JOIN for comparative analysis  
✅ **Advanced Calculations:** Percentage contribution, growth rates, rankings  
✅ **Query Optimization:** Efficient filtering and indexing strategies  

---

## 📈 Real-World Applications

This analysis demonstrates skills applicable to:
- **E-commerce Analytics** – User behavior, conversion funnels, lifetime value
- **Retail Operations** – Inventory planning, staffing optimization, supply chain
- **Marketing Analytics** – Customer segmentation, campaign ROI, cohort analysis
- **Finance/Accounting** – Revenue forecasting, profitability analysis, KPI tracking
- **Business Intelligence** – Dashboard development, data warehouse optimization

---

## 🚀 How to Use This Project

### Prerequisites
- PostgreSQL (version 12+)
- SQL IDE (pgAdmin, DBeaver, VS Code + extension)

### Setup
```bash
# 1. Create database
createdb retail_sales_db

# 2. Run the SQL script
sql project1.l.sql

# 3. Execute queries and analyze results
```

---

## 📊 Expected Outcomes

Running the complete analysis will generate:
- **14 detailed analytical queries** answering key business questions
- **Customer insights** for targeted marketing and retention
- **Revenue metrics** for performance tracking and forecasting
- **Operational metrics** for staffing and inventory decisions
- **Growth analysis** showing business momentum and seasonality

---

## 💡 Key Learnings

This project reinforces:
1. **Strategic SQL writing** – Query optimization and readability
2. **Business acumen** – Connecting technical queries to business decisions
3. **Data storytelling** – Presenting insights that drive action
4. **Problem-solving** – Breaking complex questions into SQL-solvable components

---

## 📋 Project Checklist

- ✅ Database design with proper constraints
- ✅ Data cleaning and validation
- ✅ Exploratory data analysis
- ✅ 14 advanced analytical queries
- ✅ Real-world business insights
- ✅ Production-ready code comments

---

## 🎓 Technologies & Tools

| Tool | Purpose |
|------|---------|
| **PostgreSQL** | Relational database management |
| **SQL** | Data querying and analysis |
| **Window Functions** | Advanced analytical calculations |
| **CTEs** | Complex query structuring |

---

## 💬 Questions This Analysis Answers

1. ✅ What are our best-selling product categories?
2. ✅ Who are our top 5 customers by lifetime value?
3. ✅ What's our month-over-month growth rate?
4. ✅ How do age groups and gender affect purchasing behavior?
5. ✅ Which sales shift (Morning/Afternoon/Evening) is most productive?
6. ✅ What's the contribution of each demographic segment to total revenue?
7. ✅ Which customers have the most diverse product interests?
8. ✅ How do seasonal patterns affect our revenue?
9. ✅ What's the average customer age by category?
10. ✅ Are there opportunities for cross-category marketing?

---

## 📚 SQL Concepts Covered

| Concept | Example Query |
|---------|---|
| Filtering & WHERE | Q1, Q2 |
| GROUP BY & Aggregation | Q3, Q4, Q6 |
| Window Functions | Q7, Q8, Q14 |
| CTEs & Subqueries | Q7, Q12, Q13 |
| Date Functions | Q7, Q10, Q13 |
| CASE Statements | Q10, Q13 |
| HAVING Clause | Q11 |
| CROSS JOIN | Q12 |

---

## 🔗 Files in This Repository

```
├── sql_project1_1.sql          # Complete SQL analysis (14 queries)
├── README.md                   # This file
└── SQL - Retail Sales Analysis_utf.csv         # Dataset 
```

---

## 🎯 What Recruiters Want to See

✨ **This project demonstrates:**
- 📊 Ability to extract insights from raw data
- 🔧 Mastery of advanced SQL techniques
- 💼 Business understanding (not just syntax knowledge)
- 📈 Problem-solving with data
- 📝 Clean, documented, production-ready code
- 🎓 Continuous learning mindset

---

## 📧 Contact & Next Steps

Have questions about this analysis? Let's connect!

- **LinkedIn:** [www.linkedin.com/in/navneet-singh-1916361nav]
- **Email:** [navneet65443@gmail.com]

---

## 📄 License

This project is open-source and available for educational and professional purposes.

---

<div align="center">

**⭐ If you found this analysis valuable, please consider starring this repository!**

*Last Updated: March 2026*

</div>

