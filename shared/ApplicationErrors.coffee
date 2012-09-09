util = require("util")

class ApplicationError extends Error
  constructor: (msg, type, constr) -> 
    Error.captureStackTrace this, constr or this
    @message = msg or "ApplicationError"
    @type = type or "ApplicationError"

class AuthenticationError extends ApplicationError
  constructor: (msg, type, constr) ->
    message = if msg then msg else 'Authentication Error'
    super(message, 'AuthenticationError')

class ValidationError extends ApplicationError
  constructor: (msg, type, constr) ->
    message = if msg then msg else 'Unable to save'
    super(message, 'ValidationError')

exports.ApplicationError = ApplicationError
exports.AuthenticationError = AuthenticationError
exports.ValidationError = ValidationError