const notFound = (req, res, next) => {
  res.status(404);
  next(new Error(`Route not found: ${req.originalUrl}`));
};

const errorHandler = (err, req, res, _next) => {
  let statusCode = err.statusCode || (res.statusCode === 200 ? 500 : res.statusCode);
  let message = err.message || 'Server error';

  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = 'Submitted data is invalid';
  }

  if (err.name === 'CastError') {
    statusCode = 400;
    message = 'ID invalid';
  }

  if (err instanceof SyntaxError && 'body' in err) {
    statusCode = 400;
    message = 'JSON invalid in body';
  }

  res.status(statusCode).json({
    message,
  });
};

module.exports = { notFound, errorHandler };
