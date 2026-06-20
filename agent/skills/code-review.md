# Code Review Skill

## Purpose
Review code for bugs, security issues, performance problems, and style violations.

## When to Use
- User asks for code review
- After writing new code
- Before committing changes

## Process
1. Read the code files
2. Check for common issues: null references, race conditions, SQL injection, XSS
3. Check performance: unnecessary loops, missing indexes, N+1 queries
4. Check style: naming conventions, formatting, comments
5. Provide concise feedback with file:line references

## Constraints
- Stay within free-tier limits
- Max 500 tokens per review
- Focus on critical issues first
