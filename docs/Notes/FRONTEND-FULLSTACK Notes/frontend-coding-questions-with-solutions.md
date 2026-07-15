# Frontend Coding Questions with Solutions

## 1. Build a debounce utility

### Problem
Delay function execution until the user stops triggering it for a given time.

```ts
function debounce<T extends (...args: any[]) => void>(fn: T, delay: number) {
  let timer: ReturnType<typeof setTimeout> | undefined;

  return (...args: Parameters<T>) => {
    if (timer) {
      clearTimeout(timer);
    }

    timer = setTimeout(() => {
      fn(...args);
    }, delay);
  };
}
```

Why it matters:
- search input
- resize handling
- avoiding too many API calls

## 2. Write a `useDebouncedValue` hook

```tsx
import { useEffect, useState } from "react";

export function useDebouncedValue<T>(value: T, delay: number) {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const handle = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(handle);
  }, [value, delay]);

  return debounced;
}
```

## 3. Build a `useLocalStorage` hook

```tsx
import { useEffect, useState } from "react";

export function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const raw = localStorage.getItem(key);
    return raw ? JSON.parse(raw) as T : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
}
```

## 4. Render a nested comment tree

### Problem
Given nested comments, render them recursively.

```tsx
type CommentNode = {
  id: string;
  text: string;
  children?: CommentNode[];
};

function CommentTree({ nodes }: { nodes: CommentNode[] }) {
  return (
    <ul>
      {nodes.map((node) => (
        <li key={node.id}>
          <div>{node.text}</div>
          {node.children && node.children.length > 0 && (
            <CommentTree nodes={node.children} />
          )}
        </li>
      ))}
    </ul>
  );
}
```

## 5. Filter a list by search term

```ts
type Product = {
  id: number;
  name: string;
};

function filterProducts(products: Product[], term: string) {
  const query = term.trim().toLowerCase();
  return products.filter((p) => p.name.toLowerCase().includes(query));
}
```

## 6. Merge API items by id

```ts
type Item = {
  id: string;
  name: string;
};

function mergeItems(existing: Item[], incoming: Item[]) {
  const map = new Map(existing.map((item) => [item.id, item]));

  for (const item of incoming) {
    map.set(item.id, item);
  }

  return Array.from(map.values());
}
```

## 7. Build a loading and error fetch hook

```tsx
import { useEffect, useState } from "react";

export function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function run() {
      try {
        setLoading(true);
        setError(null);
        const response = await fetch(url);
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        const json = await response.json() as T;
        if (!cancelled) {
          setData(json);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : "Unknown error");
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    run();
    return () => {
      cancelled = true;
    };
  }, [url]);

  return { data, loading, error };
}
```

## 8. Close a modal on outside click

```tsx
import { useEffect, useRef } from "react";

export function useOutsideClick(onOutside: () => void) {
  const ref = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    function handleClick(event: MouseEvent) {
      if (ref.current && !ref.current.contains(event.target as Node)) {
        onOutside();
      }
    }

    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, [onOutside]);

  return ref;
}
```

## 9. Group items by category

```ts
type Task = {
  id: string;
  category: string;
  title: string;
};

function groupByCategory(tasks: Task[]) {
  return tasks.reduce<Record<string, Task[]>>((acc, task) => {
    if (!acc[task.category]) {
      acc[task.category] = [];
    }
    acc[task.category].push(task);
    return acc;
  }, {});
}
```

## 10. Flatten route config

```ts
type RouteNode = {
  path: string;
  children?: RouteNode[];
};

function flattenRoutes(nodes: RouteNode[], prefix = ""): string[] {
  const results: string[] = [];

  for (const node of nodes) {
    const fullPath = `${prefix}${node.path}`;
    results.push(fullPath);

    if (node.children) {
      results.push(...flattenRoutes(node.children, fullPath));
    }
  }

  return results;
}
```

## Interview Guidance
- Explain time complexity where it matters.
- Mention cleanup for timers and event listeners.
- Mention loading, empty, and error states for UI problems.
- Prefer readable code over clever code in interviews.
