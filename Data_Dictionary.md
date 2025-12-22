# Olist Database - Data Dictionary

## Table of Contents
1. [Customers Table](#customers)
2. [Sellers Table](#sellers)
3. [Products Table](#products)
4. [Category Translation Table](#category_translation)
5. [Orders Table](#orders)
6. [Order Items Table](#order_items)
7. [Order Payments Table](#order_payments)
8. [Order Reviews Table](#order_reviews)
9. [Key Relationships](#relationships)

---

## Customers Table {#customers}

**Purpose:** Stores customer demographic and location information

| Column Name | Data Type | Description | Example |
|---|---|---|---|
| `customer_id` | VARCHAR(50) | **Primary Key** - Unique customer identifier | 06b8999e2fba1a6ff2af236402169e1b |
| `customer_unique_id` | VARCHAR(50) | Unique ID across multiple orders by same customer | 06b8999e2fba1a6ff2af236402169e1b |
| `customer_zip_code_prefix` | VARCHAR(10) | First 5 digits of customer's postal code | 01310 |
| `customer_city` | VARCHAR(100) | Customer's city name | são paulo |
| `customer_state` | VARCHAR(2) | Customer's state (Brazilian state code) | SP |

**Total Records:** ~100,000
**Primary Key:** customer_id
**Usage in Dashboard:** Customer segments, geographic analysis, CLV calculations

---

## Sellers Table {#sellers}

**Purpose:** Stores seller/merchant information for marketplace sellers

| Column Name | Data Type | Description | Example |
|---|---|---|---|
| `seller_id` | VARCHAR(50) | **Primary Key** - Unique seller identifier | 3442f8c38cffe371485fb33f26375be2 |
| `seller_zip_code_prefix` | VARCHAR(10) | First 5 digits of seller's postal code | 04710 |
| `seller_city` | VARCHAR(100) | Seller's city name | são paulo |
| `seller_state` | VARCHAR(2) | Seller's state (Brazilian state code) | SP |

**Total Records:** ~3,600
**Primary Key:** seller_id
**Usage in Dashboard:** Seller performance analysis, geographic seller distribution, quality assessment

---

## Products Table {#products}

**Purpose:** Stores product master data and specifications

| Column Name | Data Type | Description | Example |
|---|---|---|---|
| `product_id` | VARCHAR(50) | **Primary Key** - Unique product identifier | 1e9e8ef04869676eb03228e73270e693 |
| `product_category_name` | VARCHAR(100) | Product category (in Portuguese) | beleza_saude |
| `product_name_length` | INT | Character count of product name | 85 |
| `product_description_length` | INT | Character count of product description | 1024 |
| `product_photos_qty` | INT | Number of product photos | 5 |
| `product_weight_g` | INT | Product weight in grams | 500 |
| `product_length_cm` | INT | Product length in centimeters | 20 |
| `product_height_cm` | INT | Product height in centimeters | 10 |
| `product_width_cm` | INT | Product width in centimeters | 15 |

**Total Records:** ~32,000
**Primary Key:** product_id
**Foreign Keys:** product_category_name (references category_translation)
**Usage in Dashboard:** Product performance, category analysis, weight-based shipping analysis

---

## Category Translation Table {#category_translation}

**Purpose:** Maps Portuguese category names to English translations (lookup table)

| Column Name | Data Type | Description | Example |
|---|---|---|---|
| `product_category_name` | VARCHAR(100) | **Primary Key** - Portuguese category name | beleza_saude |
| `product_category_name_english` | VARCHAR(100) | English translation of category | beauty_health |

**Total Records:** ~71 unique categories
**Primary Key:** product_category_name
**Usage in Dashboard:** All dashboard pages for category filtering and labels

---

## Orders Table {#orders}

**Purpose:** Stores order header information and delivery tracking

| Column Name | Data Type | Description | Example |
|---|---|---|---|
| `order_id` | VARCHAR(50) | **Primary Key** - Unique order identifier | e481f51cbdc54678b7cc49136f2d6af7 |
| `customer_id` | VARCHAR(50) | **Foreign Key** → customers.customer_id | 06b8999e2fba1a6ff2af236402169e1b |
| `order_status` | VARCHAR(50) | Current order status | delivered |
| `order_purchase_timestamp` | TIMESTAMP | Date/time customer placed order | 2016-09-21 11:09:46 |
| `order_approved_at` | TIMESTAMP | Date/time order was approved/paid | 2016-09-21 11:10:05 |
| `order_delivered_carrier_date` | TIMESTAMP | Date/time order given to carrier | 2016-09-24 17:43:00 |
| `order_delivered_customer_date` | TIMESTAMP | Date/time order delivered to customer | 2016-10-26 11:23:00 |
| `order_estimated_delivery_date` | TIMESTAMP | Estimated delivery date at purchase | 2016-10-21 11:09:46 |

**Total Records:** ~100,000
**Primary Key:** order_id
**Foreign Keys:** customer_id
**Status Values:** pending, processing, invoiced, shipped, delivered, canceled
**Usage in Dashboard:** Revenue tracking, delivery performance, order trends

---

## Order Items Table {#order_items}

**Purpose:** Line-item level transactions (FACT TABLE - most granular)

| Column Name | Data Type | Description | Example |
|---|---|---|---|
| `order_id` | VARCHAR(50) | **Primary Key + Foreign Key** → orders.order_id | e481f51cbdc54678b7cc49136f2d6af7 |
| `order_item_sequence` | INT | **Primary Key** - Item sequence within order (1st, 2nd, etc.) | 1 |
| `product_id` | VARCHAR(50) | **Foreign Key** → products.product_id | 1e9e8ef04869676eb03228e73270e693 |
| `seller_id` | VARCHAR(50) | **Foreign Key** → sellers.seller_id | 3442f8c38cffe371485fb33f26375be2 |
| `shipping_limit_date` | TIMESTAMP | Latest date to ship item | 2016-09-28 17:43:00 |
| `price` | DECIMAL(10,2) | Product selling price (not including shipping) | 29.99 |
| `freight_value` | DECIMAL(10,2) | Shipping cost for this item | 9.99 |

**Total Records:** ~300,000 (one order can have multiple items)
**Primary Keys:** order_id + order_item_sequence (composite)
**Foreign Keys:** order_id, product_id, seller_id
**Usage in Dashboard:** Revenue calculations, product/seller performance, freight analysis

---

## Order Payments Table {#order_payments}

**Purpose:** Payment method and installment information

| Column Name | Data Type | Description | Example |
|---|---|---|---|
| `order_id` | VARCHAR(50) | **Primary Key + Foreign Key** → orders.order_id | e481f51cbdc54678b7cc49136f2d6af7 |
| `payment_sequential` | INT | **Primary Key** - Payment sequence (1st, 2nd, etc.) | 1 |
| `payment_type` | VARCHAR(50) | Payment method | credit_card |
| `payment_installments` | INT | Number of installments (1 = full payment) | 1 |
| `payment_value` | DECIMAL(10,2) | Amount paid with this payment method | 39.98 |

**Total Records:** ~100,000
**Primary Keys:** order_id + payment_sequential (composite)
**Foreign Keys:** order_id
**Payment Types:** credit_card, debit_card, boleto, voucher
**Usage in Dashboard:** Payment method analysis, installment impact on AOV

---

## Order Reviews Table {#order_reviews}

**Purpose:** Customer reviews and satisfaction feedback

| Column Name | Data Type | Description | Example |
|---|---|---|---|
| `review_id` | VARCHAR(50) | **Primary Key** - Unique review identifier | 1d0304b362e7896bd946edcc8d4ee688 |
| `order_id` | VARCHAR(50) | **Foreign Key** → orders.order_id | e481f51cbdc54678b7cc49136f2d6af7 |
| `review_score` | INT | Rating from 1-5 stars | 4 |
| `review_comment_title` | VARCHAR(255) | Review headline (optional) | Excellent product |
| `review_comment_message` | TEXT | Full review text (optional) | Great quality and fast shipping... |
| `review_creation_date` | TIMESTAMP | Date/time review was posted | 2016-10-28 23:45:30 |
| `review_answer_timestamp` | TIMESTAMP | Date/time seller responded (optional) | 2016-10-29 08:15:00 |

**Total Records:** ~100,000
**Primary Key:** review_id
**Foreign Keys:** order_id
**Review Score Range:** 1 (very dissatisfied) to 5 (very satisfied)
**Usage in Dashboard:** Satisfaction metrics, product/seller ratings, quality analysis

---

## Key Relationships {#relationships}

### Data Model Diagram (Star Schema)

```
                    Customers
                        ↑
                        |
                   order_id (FK)
                        |
                    ↓   |   ↓
Order Items ←── Orders ──→ Order Payments
    ↓                              ↓
    |                         Payment methods
    |
Products ←── Order Reviews
    ↓
    |
Category Translation
```

### Foreign Key Relationships

| Relationship | From Table | From Column | To Table | To Column |
|---|---|---|---|---|
| Customer Order | orders | customer_id | customers | customer_id |
| Order Items | order_items | order_id | orders | order_id |
| Item Product | order_items | product_id | products | product_id |
| Item Seller | order_items | seller_id | sellers | seller_id |
| Order Payment | order_payments | order_id | orders | order_id |
| Order Review | order_reviews | order_id | orders | order_id |
| Product Category | products | product_category_name | category_translation | product_category_name |

---

## Data Quality Notes

### Missing/NULL Values
- **order_items.product_id:** Some items have missing product data (< 1%)
- **order_reviews.review_comment_message:** Optional field, ~30% NULL
- **order_reviews.review_answer_timestamp:** Optional, only populated if seller responded
- **orders.order_delivered_customer_date:** NULL if order not yet delivered

### Data Range
- **Time Period:** September 2016 - August 2018 (24 months)
- **Order Values:** R$ 0.01 to R$ 13,664.08
- **Freight Values:** R$ 0.00 to R$ 409.68
- **Review Scores:** 1-5 stars (integers only)

### Duplicates
- **No duplicate orders:** order_id is unique
- **Multiple items per order:** Use order_item_sequence to identify
- **Multiple payments per order:** Use payment_sequential to identify
- **One review per order:** review_id is unique

### Data Integrity
- All foreign keys are properly maintained
- No orphaned records (every order_id in order_items exists in orders)
- Dates are consistent (delivery_date > purchase_date in valid orders)
- Payment values match order totals (sum of payments = order total)

---

## Column Definitions by Data Type

### VARCHAR Columns (Text)
- Max 50 chars: IDs (customer_id, order_id, product_id, seller_id, review_id)
- Max 100 chars: Names (customer_city, seller_city, product_category_name)
- Max 255 chars: Text fields (review_comment_title)

### TIMESTAMP Columns (Date/Time)
- Format: YYYY-MM-DD HH:MM:SS
- Timezone: UTC (Brazilian Time -3 to -5 hours)
- Can be NULL if event hasn't occurred yet (e.g., delivery_date for pending orders)

### INT Columns (Integers)
- Positive only: order_item_sequence, payment_installments, product_photos_qty, weights, dimensions
- Can be NULL: product_weight_g (some digital products have no weight)

### DECIMAL Columns (Money)
- 2 decimal places: All currency values (R$ Brazilian Real)
- Format: DECIMAL(10,2) = up to R$ 99,999,999.99
- Never NULL: price, freight_value always populated

---

## Common Queries & Column Usage

### For Revenue Analysis
Use: order_items.price, order_items.freight_value, orders.order_purchase_timestamp

### For Product Analysis
Use: products.*, order_items.*, order_reviews.*

### For Delivery Analysis
Use: orders.order_purchase_timestamp, orders.order_delivered_customer_date, orders.order_estimated_delivery_date

### For Customer Segmentation
Use: customers.*, orders.order_purchase_timestamp, order_items.price

### For Satisfaction Analysis
Use: order_reviews.review_score, orders.*, products.*

---

## Data Refresh Frequency

**Olist Dataset:** Static (historical data, no updates)
- Last Update: August 31, 2018
- If using live source: Check Kaggle for latest version

**Your PostgreSQL Database:** Manual updates
- Refresh views after data changes: `REFRESH MATERIALIZED VIEW view_name;`
- Re-export to Power BI: Refresh in Power BI Desktop or Power BI Service