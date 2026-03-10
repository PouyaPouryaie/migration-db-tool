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

| Command|                              Description                               | Example                                                                                                                                     |
| :--- |:----------------------------------------------------------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------|
| update | Applies any changesets not yet present in the DATABASECHANGELOG table. | `./mvnw liquibase:update`                                                                                                                   |
| status |   Shows a list of pending changesets that have not yet been applied.   | `./mvnw liquibase:status`                                                                                                                   |
| rollback |    Reverts changes based on a tag or count. WARNING: Use with care!    | `./mvnw liquibase:rollback -Dliquibase.rollbackCount=1` (Undo the last change) or `./mvnw liquibase:rollback v1.0` (Undo to a specific tag) |
| history |   Displays all changesets already applied to the database.    | `./mvnw liquibase:history`                                                                                                                  |


#### Deploying to a Specific Version (update-to-tag)

If your changelog contains multiple versions, but you only want to deploy up to a specific milestone (e.g., for a Production release while Development continues), use update-to-tag.

<b>Command:
```Bash

# Syntax: ./run-liquibase.sh update-to-tag <tag_name>
./run-liquibase.sh update-to-tag v1.0
```

How it works:
- Liquibase reads the changelog-master.yaml.
- It executes all pending changesets until it reaches the changeset containing tag: v1.0.
- It stops there. Any changesets defined below that tag remain "pending" and are not executed.


### 🛡️ Safety Testing

Before deploying to production, it is recommended to run a "Test Rollback" to ensure all changes are reversible.
```Bash

./run-liquibase.sh update-testing-rollback
```

This command performs an update, followed by a rollback, and a final update. If this command succeeds, it guarantees that your migration scripts are fully reversible.

## Running with Docker

There are two approaches to running Liquibase using Docker. Choose the one that best fits your workflow.

### Approach 1: Custom Wrapper (Manual Command Injection)

This approach uses a custom `Dockerfile` where the Liquibase command is treated as a generic environment variable (`COMMAND`). This is useful if you want to bake specific shell logic or pre-processing into your image.

**1. Build the image:**

```bash
docker build -t my-liquibase:latest -f liquibase-xml-docker-file.yaml .

```

**2. Run the migration:**

> **Note:** Replace the IP address with your database instance IP (e.g., `172.17.0.1` for the Docker host).

```bash
docker run --rm --network bridge \
  -v $(pwd)/src/main/resources/liquibase-xml:/liquibase/changelog \
  --env DB_URL="jdbc:postgresql://172.17.0.1:5432/migration_tool" \
  --env DB_USER="postgres" \
  --env DB_PASSWORD="postgres" \
  --env COMMAND="status" \
  my-liquibase:latest

```

---

### Approach 2: Native Liquibase Environment Variables (Recommended)

This approach leverages the built-in configuration engine of the official Liquibase image. It follows the **"Environment over Configuration"** pattern, making your `Dockerfile` significantly simpler and avoiding shell parsing errors.

**1. Build the image:**

```bash
docker build -t my-liquibase:latest -f liquibase-yaml-docker-file.yaml .

```

**2. Run the migration:**
In this mode, you pass specific `LIQUIBASE_` variables. The final argument in the command (`status`, `update`, `rollback`, etc.) tells Liquibase exactly what action to perform.

```bash
docker run --rm --network bridge \
  -v $(pwd)/src/main/resources/db/changelog:/liquibase/changelog \
  --env LIQUIBASE_COMMAND_URL="jdbc:postgresql://172.17.0.1:5432/migration_tool" \
  --env LIQUIBASE_COMMAND_USERNAME="postgres" \
  --env LIQUIBASE_COMMAND_PASSWORD="postgres" \
  --env LIQUIBASE_COMMAND_CHANGELOG_FILE="changelog-master.yaml" \
  my-liquibase:latest \
  status

```

#### Key Variables Explained:

| Variable | Description |
| --- | --- |
| `LIQUIBASE_COMMAND_URL` | The JDBC connection string for your database. |
| `LIQUIBASE_COMMAND_CHANGELOG_FILE` | The path to your root changelog file inside the container. |
| `status` / `update` | The Liquibase command to execute (passed as the container's `CMD`). |

---

Adding an option for a `liquibase.properties` file is a great way to make the tool "plug-and-play" for local developers. This allows them to configure their database once and run the container without typing long strings of environment variables.

Here is the section you can add to your **README.md**:

---

### Approach 3: Using a Local Properties File

For local development, you can store your configuration in a `liquibase.properties` file. This is the most convenient method as it avoids long terminal commands and keeps your configuration organized.

**1. Create a `liquibase.properties` file** in your project root or at a specific directory like `resoureces/db/local/liquibase-local.properties`:

```properties
# Connection Details
url=jdbc:postgresql://172.17.0.1:5432/migration_tool
username=postgres
password=postgres

# Changelog Configuration
changeLogFile=changelog-master.yaml

```

**2. Run the migration:**
We mount the properties file directly into the `/liquibase/changelog` directory. Liquibase automatically detects and uses it.
Note: We mount the file directly into the `/liquibase/changelog directory` (the WORKDIR). By using `--defaultsFile`, we ensure Liquibase loads these settings before executing the status command.

```bash
docker run --rm \
  --network bridge \
  -v $(pwd)/src/main/resources/db/changelog:/liquibase/changelog \
  -v $(pwd)/src/main/resources/db/local:/liquibase/config \
  my-liquibase:latest \
  --defaultsFile=/liquibase/config/liquibase-local.properties \
  status

```

#### Why use this approach?

* **Simplicity:** You only need to type the command (e.g., `status`, `update`) at the end of the Docker string.
* **Consistency:** All team members can use the same property keys, changing only the values specific to their local setup.
* **Overrides:** You can still override any property in the file by passing an environment variable in the `docker run` command.

> **⚠️ Security Note:** Ensure `liquibase.properties` is added to your `.gitignore` file to prevent sensitive database credentials from being committed to version control.

---

### Summary Table: Which approach to use?

| Method | Best For... | Key Benefit |
| --- | --- | --- |
| **Approach 1 (CMD)** | Custom logic | Useful for specific shell-scripting needs. |
| **Approach 2 (Env Vars)** | CI/CD Pipelines | Best for automation and secure secret injection. |
| **Approach 3 (Properties)** | Local Dev | Cleanest terminal commands for daily development. |

---

**Would you like me to create a "Troubleshooting" section for your README to cover common errors like the "relation does not exist" issue we solved earlier?**

### 💡 Pro-Tip: Docker Networking

If you are running your database in a separate Docker container, using the default `bridge` network requires you to use the Host IP (e.g., `172.17.0.1`).

For a more stable setup, create a **user-defined network**. This allows you to connect using the container name (e.g., `postgres`) instead of an IP address:

```bash
# 1. Create a network
docker network create liquibase-net

# 2. Run your DB on that network
docker run -d --name postgres --network liquibase-net -e POSTGRES_PASSWORD=password postgres

# 3. Run Liquibase using the name 'postgres'
docker run --rm --network liquibase-net \
  --env LIQUIBASE_COMMAND_URL="jdbc:postgresql://postgres:5432/migration_tool" \
  ...

```
---
## 📝 License

This project is licensed under the MIT License. Feel free to copy and adapt the configuration for your own projects!