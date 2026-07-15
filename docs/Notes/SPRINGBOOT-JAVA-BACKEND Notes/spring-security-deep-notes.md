# Spring Security Deep Notes

This note focuses specifically on Spring Security concepts, interview expectations, and production concerns.

---

## 1. Authentication vs Authorization

### Authentication

- verifies identity

### Authorization

- decides access rights

### Strong interview line

Authentication answers "who are you?" and authorization answers "what are you allowed to do?"

---

## 2. SecurityFilterChain

Modern Spring Security configuration commonly uses `SecurityFilterChain`.

Example:

```java
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/auth/**").permitAll()
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            );

        return http.build();
    }
}
```

### What to explain

- why certain endpoints are public
- how protected routes are enforced
- whether the service is session-based or stateless

---

## 3. Password Security

Passwords should never be stored in plain text.

Use `PasswordEncoder`, commonly BCrypt.

```java
PasswordEncoder encoder = new BCryptPasswordEncoder();
```

### Strong answer

Passwords are hashed, not decrypted later. Login works by comparing a raw candidate password with the stored hash through the encoder.

---

## 4. Session vs Token Security

### Session-based

- common for web applications
- server maintains session state

### Token-based

- common for APIs
- often JWT-based
- supports stateless services

### Tradeoff

Token-based designs reduce server session state, but token validation, expiry, revocation, and secret handling become important.

---

## 5. JWT Basics

Typical JWT API flow:

1. user logs in
2. server validates credentials
3. server issues token
4. client sends `Authorization: Bearer <token>`
5. filter validates token and sets authentication

### Common mistakes

- ignoring expiration
- weak signature validation
- putting sensitive data in token payload

---

## 6. Method-Level Security

Useful annotations:

- `@PreAuthorize`
- `@Secured`
- `@RolesAllowed`

Example:

```java
@PreAuthorize("hasRole('ADMIN')")
public void deleteUser(Long id) {
}
```

### Why it matters

Endpoint rules protect routes. Method-level rules protect business actions themselves.

---

## 7. Production Security Concerns

Senior answers should mention:

- least privilege
- actuator exposure
- secret safety
- logging without leaking credentials
- safe rollout of auth changes

### Strong answer

Security changes can break valid traffic or expose sensitive endpoints, so I validate access rules, environment config, and rollback strategy before production rollout.
