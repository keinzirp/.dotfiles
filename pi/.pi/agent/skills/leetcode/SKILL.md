---
name: leetcode
description: Set up or maintain a local Python LeetCode exercise in ~/Development/Other/leetcode without solving it. Use when the user provides a LeetCode title, number, or URL, or asks to import a problem.
---

# Local LeetCode

Use the user's local workspace:

```text
~/Development/Other/leetcode
```

This workspace keeps exercises as single Python files at its root. Do not create a problem directory or a `main.py` file. For a title such as `518. Coin Change II`, create or update:

```text
~/Development/Other/leetcode/518-coin-change-ii.py
```

## Workflow

1. Slugify the supplied title: lowercase it; replace whitespace and punctuation with hyphens; collapse repeated hyphens; remove leading and trailing hyphens. Preserve the problem number when supplied.
2. Retrieve the problem description, examples, and Python function signature from the LeetCode URL or web search. If unavailable, ask the user to paste them.
3. Create the root-level `.py` file. Comment every description line with `# `. Add only imports required by the supplied template, then add the template unchanged.
4. Add two blank lines before an `if __name__ == "__main__":` block. Put runnable example calls there, print actual and expected values, and assert direct comparable outputs. For outputs with multiple valid forms, write a validator in the test block rather than asserting one exact result.
5. Run `python3 ~/Development/Other/leetcode/<slug>.py` and show the result.

## Learning policy

- Never implement, edit, debug, optimize, or hint at the user's solution.
- Do not alter the supplied solution template.
- After setup, only change imports, the commented problem description, or the `__main__` test harness.
- Python 3 is the default unless the user says otherwise.
- Do not use an f-string when there is no interpolation.
