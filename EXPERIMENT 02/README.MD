# EXPERIMENT 2 - ER DIAGRAM TO RELATIONAL SCHEMA

## Aim

To convert the ER diagram of an Indian e-commerce platform into a relational schema and implement the database using MySQL.

## Objective

To create relational tables using Primary Keys, Foreign Keys, NOT NULL, UNIQUE, ON DELETE CASCADE, and ON DELETE SET NULL constraints.

## Database

**MySQL**

## Tables

- Customer
- Seller
- Category
- Address
- Product
- Orders
- OrderItem
- Payment
- Delivery
- PhysicalProduct
- DigitalProduct

## Concepts Implemented

- Primary Key
- Foreign Key
- Composite Primary Key
- NOT NULL Constraint
- UNIQUE Constraint
- CHECK Constraint
- Referential Integrity
- ON DELETE CASCADE
- ON DELETE SET NULL
- Product Specialization

## Referential Integrity

The experiment demonstrates foreign key violations by attempting to insert records containing non-existing foreign key values.

Examples:

- Order with a non-existing CustomerID
- OrderItem with a non-existing ProductID

Other constraint violations are also demonstrated:

- NOT NULL violation
- UNIQUE constraint violation
- PRIMARY KEY violation
- Composite key violation

## ON DELETE CASCADE

When an Order is deleted, its related OrderItem, Payment, and Delivery records are automatically deleted.

## ON DELETE SET NULL

When a Seller or Category is deleted, the related Product records remain, but their corresponding SellerID or CategoryID is set to NULL.

## Files

`EXP2_ER_TO_RELATIONAL_SCHEMA.sql`

## Conclusion

The ER diagram was successfully converted into a relational database schema and implemented in MySQL. Primary keys, foreign keys, integrity constraints, cascading actions, sample data, and referential integrity violations were demonstrated.