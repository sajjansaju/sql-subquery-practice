# 🛒 RetailDB SQL Practice Project

This repository contains a fully structured PostgreSQL dataset designed for hands-on practice with SQL concepts such as **joins**, **subqueries (correlated & uncorrelated)**, **aggregations**, and **filtering**. It includes a `RetailDB` schema simulating a simple e-commerce business with customers, orders, products, categories, and payments.

## 📁 Contents

- `retaildb_schema.sql` – SQL script to create and populate the database
- `retaildb_queries.sql` – A set of 17 SQL queries demonstrating advanced SQL techniques
- `README.md` – Project overview and instructions

---

## 🧱 Database Schema

The project includes 6 core tables:

- `customers` – Customer profiles and signup dates
- `categories` – Product categories
- `products` – Products with pricing and category info
- `orders` – Customer orders with status
- `order_items` – Line items in each order
- `payments` – Payment details for orders


## 🧩 Entity-Relationship Diagram (ERD)

The following ERD (Chen's Notation with cardinality) illustrates how the tables in the RetailDB schema are related:

![RetailDB Chen ERD with Cardinality](retaildb_chen_erd_cardinality.png)

### 📝 Diagram Notes:
- A **Customer** can place **many Orders**
- An **Order** can include **many Order Items**
- Each **Order Item** refers to **one Product**
- A **Product** belongs to **one Category**
- Each **Order** is associated with **one Payment**

This visualization helps understand the relationships and cardinalities between entities, which is especially useful when working with joins and subqueries.
