# 💧 Spring Boot & Liquibase Example: Safe Schema Management

A practical demonstration of Liquibase — an essential, open-source tool for tracking, versioning, and applying database schema changes across development, staging, and production environments.

This repository showcases how to use Liquibase with Spring Boot to manage database state safely and consistently. It features rollbacks, status checks, and repeatable migrations, ensuring your application schema is always up-to-date.

## 🌟 Features Demonstrated

* **Declarative Changesets:** Managing schema changes using descriptive XML (or YAML/SQL) instead of imperative scripts.
* **Automatic Migration:** Spring Boot automatically runs Liquibase migrations on application startup.
* **Rollback Functionality:** Using the command line to safely revert specific changesets.
* **Database History Tracking:** How Liquibase uses the `DATABASECHANGELOG` table to track applied changes.
* **Contexts & Labels:** Applying specific changesets only to certain environments (e.g., test data only in dev).

---

## 🛠️ Project Setup

### Prerequisites
* **Java 17+** (as specified in `pom.xml`)
* **Maven 3.6+**
* **PostgreSQL** (Running instance)

### Running Locally
1.  **Clone the Repository:** `git clone https://github.com/PouyaPouryaie/migration-db-tool.git`
2.  **Navigate to Directory:** `cd migration-db-tool`
3.  **Build the Application:**
    `./mvnw clean install`
4.  **Run the Application (Automatic Migration):**
    When the application starts, it automatically detects and applies new changesets found in `src/main/resources/db/changelog/`.
    `./mvnw spring-boot:run`
    *Check console output for logs indicating Liquibase is reading the changelog and applying changes.*

---

## 📂 Liquibase Structure

### Yaml Sample

The project uses a structured directory under `src/main/resources/db/` to separate configuration from migrations:

```text
src/main/resources/db/
├── local/
│   └── liquibase-local.properties  <-- Local DB Credentials
└── changelog/
    ├── changelog-master.yml        <-- Entry Point
    └── changesets/                 <-- Migration Scripts (SQL/XML)
```

### XML Sample
For see the XML sample, Navigate to `src/main/resources/liquibase-xml` to find `changelog-master.xml`. This is the main entry point that includes individual versioned files in order:

```xml
<databaseChangeLog>
    <include file="changesets/2025-10/master.xml" relativeToChangelogFile="true"/>
    </databaseChangeLog>
```

### Example Changeset (`create-example-table.sql`)
Each file contains atomic scripts. Notice the `<rollback>` tag, which defines the SQL to undo the change:

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

---

## ⚙️ Advanced Liquibase Commands

For manual database management, we use the official Liquibase Docker image. We mount the parent `db` folder to `/liquibase/db` inside the container so it can access both your properties and your changelogs.

| Command | Description | Docker Example                                                                                                                                                                          |
| :--- | :--- |:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **status** | Check for pending changes. | `docker run --rm -v $(pwd)/src/main/resources/db:/liquibase/db my-liquibase:latest --defaultsFile=/liquibase/db/local/liquibase-local.properties status`                                |
| **update** | Apply all migrations. | `docker run --rm -v $(pwd)/src/main/resources/db:/liquibase/db my-liquibase:latest --defaultsFile=/liquibase/db/local/liquibase-local.properties update`                                |
| **rollback** | Undo the last change. | `docker run --rm -v $(pwd)/src/main/resources/db:/liquibase/db my-liquibase:latest --defaultsFile=/liquibase/db/local/liquibase-local.properties rollback --tag=v1.0` |
| **history** | View the migration log. | `docker run --rm -v $(pwd)/src/main/resources/db:/liquibase/db my-liquibase:latest --defaultsFile=/liquibase/db/local/liquibase-local.properties history`                               |


### Deploying to a Specific Version (`update-to-tag`)
Use this to deploy only up to a specific milestone (e.g., for a Production release).
**Command:**
```bash
  docker run --rm -v $(pwd)/src/main/resources/db:/liquibase/db \
  my-liquibase:latest --defaultsFile=/liquibase/db/local/liquibase-local.properties \
  update-to-tag v1.0
```

**How it works:**
* Liquibase reads the `changelog-master.yaml`.
* Executes pending changesets until it reaches the tag `v1.0`.
* Stops there; subsequent changesets remain "pending."

### 🛡️ Safety Testing
Before production deployment, run a "Test Rollback":
**Command:**
```bash
  docker run --rm -v $(pwd)/src/main/resources/db:/liquibase/db \
  my-liquibase:latest --defaultsFile=/liquibase/db/local/liquibase-local.properties \
  update-testing-rollback
```

*This performs an update, a rollback, and a final update to guarantee scripts are fully reversible.*

---

To keep your README consistent with the professional and developer-friendly tone of your blog post, we should add an **"Advanced Schema Control"** section. This section will bridge the gap between simple migrations and production-grade safety.

Here is the markdown block you can insert before the **"Docker"** section:

---

## 🚀 Advanced Schema Control

As your project grows, "simple" migrations aren't enough. Liquibase provides tools to ensure your scripts are safe, environment-aware, and database-compatible.

### 1. Preconditions: Safety First
Preconditions allow you to verify the state of the database *before* a changeset runs. This prevents common errors like trying to create a table that already exists.

```yaml
databaseChangeLog:
  - changeSet:
      id: secure-customer-update
      author: pouya
      preConditions:
        - onFail: MARK_RAN   # If the check fails, skip and mark as finished
        - onError: HALT      # If there is a syntax error, stop everything
        - not:
            tableExists:
              tableName: customer
      changes:
        - sqlFile: 
            path: "create-customer.sql"
```

* **`onFail`**: Triggered when the condition is false (e.g., table already exists).
    * `HALT`: Stops the entire migration.
    * `MARK_RAN`: Skips the changeset but records it as "executed."
    * `CONTINUE`: Skips it but doesn't record it (will try again next time).
* **`onError`**: Triggered when a technical error occurs (e.g., invalid SQL syntax in the check).
* **More info:** For a full list of checks (like `columnExists`, `sqlCheck`, or `indexExists`), see the [Official Liquibase Preconditions Doc](https://docs.liquibase.com/concepts/changelogs/preconditions.html).

### 2. Multi-DBMS Support
If your team uses **PostgreSQL** for production but **H2** for local integration tests, you can use the `dbms` attribute to ensure scripts only run on the correct engine.

```yaml
  - changeSet:
      id: postgres-specific-optimization
      author: pouya
      dbms: postgresql  # This changeset will be ignored if running on H2 or Oracle
      changes:
        - sql:
            sql: "CREATE INDEX idx_cust_json ON customer USING gin (data);"
```

or on the SQL scripts
```sql
-- changeset pouya:0 dbms:postgresql
CREATE TABLE customer (
   id serial PRIMARY KEY,
   name varchar(255) NOT NULL,
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3. Contexts: Environment-Aware Migrations
Contexts allow you to "tag" changesets so they only run in specific environments. In this project, we use them to separate core schema from environment-specific data.

**How the filtering works:**
* **Matched Context:** If you run with `--contexts=prod`, only changesets marked `context: prod` will run.
* **Mismatched Context:** Changesets marked `context: dev` will be **ignored** during a `prod` run.
* **Global Changesets:** Any changeset **without** a context attribute is considered "Global." These will run in **every** environment, regardless of your runtime settings.

| Changeset Attribute | Running with `--contexts=prod` | Running with `--contexts=dev` |
| :--- | :--- | :--- |
| `context: prod` | ✅ Runs | ❌ Skipped |
| `context: dev` | ❌ Skipped | ✅ Runs |
| *(No context)* | ✅ Runs (Global) | ✅ Runs (Global) |

> **Pro-Tip:** Use contexts for loading "Mock Data" or "Test Users" in your local environment without risking that data reaching your Production database.

**Sample In the Changelog:**
```yaml
  - changeSet:
      id: load-dev-data
      author: pouya
      context: local or dev
      changes:
        - insert:
            tableName: customer
            columns:
              - column: {name: "name", value: "Demo User"}
```

**How to Execute:**
You must pass the context at runtime. If no context is passed, all changesets (including those with no context defined) will run.
- Via Docker/CLI:
`liquibase --contexts=local update`

- Via Spring Boot (application.yml):
```YAML
    spring:
      liquibase:
        contexts: prod
 ```

## 🐳 Running with Docker

Choose the approach that fits your workflow.

### Approach 1: Custom Wrapper (Manual Command Injection)
Useful for baking specific shell logic or pre-processing into your image.
1.  **Build:** `docker build -t my-liquibase:latest -f liquibase-xml-docker-file.yaml .`
2.  **Run:** 
    ```bash
    docker run --rm --network bridge \
    -v $(pwd)/src/main/resources/liquibase-xml:/liquibase/changelog \
    --env DB_URL="jdbc:postgresql://172.17.0.1:5432/migration_tool" \
    --env DB_USER="postgres" \
    --env DB_PASSWORD="postgres" \
    --env COMMAND="status" \
    my-liquibase:latest
    ```

### Approach 2: Native Environment Variables (Recommended)
Leverages the official Liquibase image configuration engine (Environment over Configuration).
1.  **Build:** `docker build -t my-liquibase:latest -f liquibase-yaml-docker-file.yaml .`
2.  **Run:**
    ```bash
    docker run --rm --network bridge \
      -v $(pwd)/src/main/resources/db/changelog:/liquibase/changelog \
      --env LIQUIBASE_COMMAND_URL="jdbc:postgresql://172.17.0.1:5432/migration_tool" \
      --env LIQUIBASE_COMMAND_USERNAME="postgres" \
      --env LIQUIBASE_COMMAND_PASSWORD="postgres" \
      --env LIQUIBASE_COMMAND_CHANGELOG_FILE="changelog-master.yaml" \
      my-liquibase:latest status
    ```

### Approach 3: Using a Local Properties File
Most convenient for local development. Create a file at `src/main/resources/db/local/liquibase-local.properties`:
```properties
url=jdbc:postgresql://172.17.0.1:5432/migration_tool
username=postgres
password=postgres
changeLogFile=changelog-master.yaml
```
**Run:**
```bash
docker run --rm --network bridge \
  -v $(pwd)/src/main/resources/db/changelog:/liquibase/changelog \
  -v $(pwd)/src/main/resources/db/local:/liquibase/config \
  my-liquibase:latest --defaultsFile=/liquibase/config/liquibase-local.properties status
```
*Note: Ensure `liquibase.properties` is in your `.gitignore`.*

---

## 📊 Summary of Docker Methods

| Method | Best For... | Key Benefit |
| :--- | :--- | :--- |
| **Approach 1 (CMD)** | Custom logic | Flexibility for shell scripting. |
| **Approach 2 (Env Vars)** | CI/CD Pipelines | Secure secret injection and automation. |
| **Approach 3 (Properties)** | Local Dev | Cleanest terminal commands; plug-and-play. |

---

### 💡 Pro-Tip: Docker Networking
For a stable setup, use a **user-defined network** to connect via container name instead of Host IP:
```bash
docker network create liquibase-net
docker run -d --name postgres --network liquibase-net -e POSTGRES_PASSWORD=password postgres
docker run --rm --network liquibase-net --env LIQUIBASE_COMMAND_URL="jdbc:postgresql://postgres:5432/migration_tool" ...
```

---

## 📝 License
This project is licensed under the MIT License. Feel free to copy and adapt it!
