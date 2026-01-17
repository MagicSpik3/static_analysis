This is a classic legacy code dilemma. You are right to hesitate on the "100% test coverage" idea, especially since you cannot currently run the existing tests.

Trying to retrofit 100% unit test coverage onto a codebase with "confusing flow" and "badly named variables" before you understand it is often a trap. You will likely end up writing brittle tests that cement the bad structure in place, making refactoring harder, not easier.

Here is a breakdown of why you should prioritize the **Dictionary (Static Analysis)** approach combined with a specific type of high-level testing.

---

### 1. Why "100% Test Coverage" is the Wrong First Step

If you aim for 100% coverage now, you face three major hurdles:

* **The "Run" Barrier:** You stated you can't run the tests. Fixing the environment to run granular unit tests on broken code is often more expensive than fixing the code itself.
* **Coupling to Implementation:** Writing unit tests for a function with "confusing flow" usually requires mocking internal state. When you later refactor that flow, you will break those tests, meaning you did double the work.
* **False Confidence:** Tests on badly named variables (like `r`) verify that the math works, but they don't verify *intent*. You might lock in a bug assuming it's a feature.

**The Better Alternative:**
Instead of unit tests, aim for **Characterization Tests (Golden Master)**.

1. Treat the messy code as a "Black Box."
2. Fix the environment just enough to run the main entry point.
3. Feed it a specific input data set.
4. Record the exact output (even if it's wrong/messy).
5. Use this "Golden Master" to ensure your refactoring doesn't change the output.

### 2. The "Dictionary" Strategy (Static Analysis)

You are on the right track here. Since R is highly dynamic, building a metadata dictionary (essentially a **Symbol Table** or **Call Graph**) is the safest way to tackle renaming variables like `r`.

Since you are building this tool in R, you should leverage R's introspection capabilities. You are looking to capture:

1. **Variable Definitions:** Where is `r` assigned?
2. **Variable Usage:** Where is `r` read?
3. **Scope Boundaries:** Is `r` inside a function, a closure, or the global environment?

#### How to implement this in R

You don't need to write a text parser from scratch. R has built-in tools to generate this "dictionary" for you.

**A. `getParseData()**`
This is your best friend. It tokenizes R code and gives you a data frame containing the line number, column, token type (SYMBOL, LEFT_ASSIGN, etc.), and parent IDs.

* **Goal:** Filter this table for `text == "r"`.
* **Context:** Check the `parent` column to see if it is part of a function call or an assignment.

**B. `codetools::walkCode()**`
This is a more advanced approach used by R's own CRAN checks. It walks the code tree and allows you to hook into specific events (like "when a leaf node is found"). This helps you differentiate between `r` the variable and `r` as a column name in a dataframe (which `getParseData` might struggle to distinguish without context).

### 3. Recommended Workflow

Don't try to refactor manually yet. Use your tool to assist the refactor.

**Phase 1: Knowledge Gathering (Your "Dictionary")**
Build your tool to generate a report answering these questions for every function:

* **Inputs:** What arguments does it take?
* **Globals:** What global variables does it access? (Look for `<<-` or usage without assignment).
* **Dependencies:** What other functions does it call?

**Phase 2: The Safety Net**
Create a single integration test (Golden Master) that runs the script end-to-end. Do not worry about unit tests for the small, messy functions yet.

**Phase 3: Assisted Refactoring**
Use the data from Phase 1 to rename variables safely.

* *Example:* If your tool identifies that `r` is a local variable in function `X` and is never accessed globally, you can script a rename of `r` to `rates_table` *only within that scope*.

### Summary

| Strategy | Verdict | Why? |
| --- | --- | --- |
| **100% Coverage** | **Avoid** | Too much effort to test "bad" code; locks in bad architecture. |
| **Fix "Run" capability** | **Essential** | You cannot refactor code you cannot run. Prioritize getting it executable. |
| **Static Analysis** | **Do this** | Map the variable scopes using `getParseData`. This gives you the confidence to rename. |

### Proposed Next Step

Would you like me to sketch out a small R function using `getParseData()` that takes a file path and returns a list of all variables named `r` along with their line numbers and whether they appear to be assignments or usages?

# Example usage
df_r <- analyze_variable_usage("legacy_script.R", "r")
df_t <- analyze_variable_usage("legacy_script.R", "t")

# Combine them
master_log <- rbind(df_r, df_t)