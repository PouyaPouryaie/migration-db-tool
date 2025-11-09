# 💧 Spring Boot & Liquibase Example: Safe Schema Management

A practical demonstration of Liquibase, an essential, open-source tool for tracking, versioning, and applying database  <br>
schema changes across development, staging, and production environments. <br>
This repository showcases how to use Liquibase with Spring Boot to manage the database state safely and consistently,  <br>
providing features like rollbacks, status checks, and repeatable migrations, ensuring that your application schema is always up-to-date.

## 🌟 Features Demonstrated

- Declarative Changesets: Managing schema changes using descriptive XML (or YAML/SQL) instead of imperative scripts.
- Automatic Migration: Spring Boot automatically runs Liquibase migrations on application startup.
- Rollback Functionality: Using the command line to safely revert specific changesets.
- Database History Tracking: How Liquibase uses the DATABASECHANGELOG table to track applied changes.
- Contexts & Labels: Applying specific changesets only to certain environments (e.g., test data only in dev).

## 🛠️ Project Setup

Prerequisites
- Java 17+ (or relevant version specified in pom.xml)
- Maven 3.6+
- A running PostgreSQL

Running Locally
- Clone the Repository: git clone [Migration DB Tool](https://github.com/PouyaPouryaie/migration-db-tool.git)
- cd `migration-db-tool` Directory

Build the Application:
- ./mvnw clean install

Run the Application (Automatic Migration):
When the Spring Boot application starts, it automatically detects and applies any new Liquibase changesets found in <br>
the `src/main/resources/db/changelog/` directory.

- ./mvnw spring-boot:run
- Check your console output: You will see logs indicating that Liquibase is reading the changelog and applying the changesets.

## 📂 Liquibase Structure

All database migration files are located under `src/main/resources/db/changelog/.` or your custom directory (ex: `liquibase-xml` folder)

## Xml sample
- Navigate to `src/main/resources/liquibase-xml`
- You can find `changelog-master.xml` file

This is the main entry point (the master file). It simply includes all individual, versioned migration files in the correct order.

```xml
<databaseChangeLog>
    <!-- Include individual versioned changelog files -->
    <include file="changesets/2025-10/master.xml" relativeToChangelogFile="true"/>
    <!--  Rest of the change logs  -->
</databaseChangeLog>
```

### Example Changeset (create-example-table.sql)

Each file contains one or more atomic scripts:

```sql
-- liquibase formatted sql

-- changeset liquibase:0
CREATE TABLE example_table (
    id serial PRIMARY KEY,
    name varchar(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- rollback DROP TABLE example_table
```

- Notice the <rollback> tag: this defines the exact SQL to undo the change, making rollbacks safe.

### ⚙️ Advanced Liquibase Commands

Because this project is configured with the Liquibase Maven plugin, you can run commands directly against your target <br>
database without starting the Spring Boot application.

| Command|                              Description                               | Example                                                                        |
| :--- |:----------------------------------------------------------------------:|:-------------------------------------------------------------------------------|
| update | Applies any changesets not yet present in the DATABASECHANGELOG table. | `./mvnw liquibase:update`                                                      |
| status |   Shows a list of pending changesets that have not yet been applied.   | `./mvnw liquibase:status`                                                      |
| rollback |    Reverts changes based on a tag or count. WARNING: Use with care!    | `./mvnw liquibase:rollback -Dliquibase.rollbackCount=1` (Undo the last change) |
| history |   Displays all changesets already applied to the database.    | `./mvnw liquibase:history`                        |


## 📝 License

This project is licensed under the MIT License. Feel free to copy and adapt the configuration for your own projects!