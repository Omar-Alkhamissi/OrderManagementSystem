# OrderManagementSystem

OrderManagementSystem is a SQL Server database project for suppliers, customers, employees, products, orders, and related reporting functions.

## Features

- Order-management schema with supplier, customer, employee, product, order, and detail tables
- Seed data for local development and query testing
- Stored functions for reusable order-management calculations

## Tech Stack

- Microsoft SQL Server
- T-SQL

## Getting Started

Run the scripts in this order from SQL Server Management Studio or Azure Data Studio:

```text
OrderManagementSystem(schema).sql
OrderManagementSystem(data).sql
OrderManagementSystem(functions).sql
```

## Project Structure

- `OrderManagementSystem(schema).sql`: table and relationship definitions
- `OrderManagementSystem(data).sql`: seed data
- `OrderManagementSystem(functions).sql`: helper functions
