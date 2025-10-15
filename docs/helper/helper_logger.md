# HelperLogger Manual

HelperLogger is a simple, structured logging helper for Rails applications. It wraps `Rails.logger` and provides consistent log entries with useful context.

---

## Features

- Structured log output (JSON)
- Includes timestamp, log level, class, message, and extra data
- Supports all standard Rails log levels (`debug`, `info`, `warn`, `error`, `fatal`, `unknown`)
- Easy to use in controllers, models, services, etc.

---

## Example Log Output

```json
{
  "timestamp": "2025-08-23T12:34:56Z",
  "level": "WARN",
  "class": "MyClass",
  "message": "Something happened",
  "extra": { "user_id": 123 }
}
```

---

## Usage

### Basic Usage

```ruby
HelperLogger.info("Process started")
HelperLogger.warn("Something happened", klass: self.class.name)
HelperLogger.error("Error occurred", extra: {error_code: 500})
```

### With Extra Data

```ruby
HelperLogger.info(
  "User login",
  klass: self.class.name,
  extra: { user_id: current_user.id, request_id: request.uuid }
)
```

### All Log Levels

```ruby
HelperLogger.debug("Debug info")
HelperLogger.info("Information")
HelperLogger.warn("Warning")
HelperLogger.error("Error")
HelperLogger.fatal("Fatal error")
HelperLogger.unknown("Unknown situation")
```

---

## Parameters

- `message` (String): The log message.
- `klass` (String, optional): The class or context. Defaults to the calling method name.
- `extra` (Hash, optional): Any additional data to include in the log entry.

---

## Integration

HelperLogger is auto-loaded via an initializer. You can use it anywhere in your Rails app without requiring it manually.

---

## Best Practices

- Use `klass: self.class.name` for clarity in logs.
- Pass relevant context in `extra` (e.g., `user_id`, `request_id`, error details).
- For consistency with Lograge, use similar keys in `extra`.

---

## Troubleshooting

If you see `uninitialized constant HelperLogger`, ensure:

- The file is present at `app/lib/helper_logger.rb`
- The initializer requires it (see `config/initializers/helper_logger.rb`)

---

## Extending

You can add more fields to the log entry or customize the format as needed. For example, include tags, environment, or request parameters.

---

## Contact

For questions or improvements, contact the development team or refer to the main documentation.
