import logging
import time
import json

logger = logging.getLogger('django')

class RequestLoggingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Start time of request
        start_time = time.time()

        # Log request details
        logger.info(f"Request: {request.method} {request.path} from {request.META.get('REMOTE_ADDR')}")
        
        # Log request headers
        headers = {k: v for k, v in request.META.items() if k.startswith('HTTP_')}
        logger.debug(f"Request Headers: {json.dumps(headers, indent=2)}")

        # Get the response
        response = self.get_response(request)

        # Calculate request duration
        duration = time.time() - start_time

        # Log response details
        logger.info(
            f"Response: {request.method} {request.path} completed in {duration:.2f}s "
            f"with status {response.status_code}"
        )

        return response

    def process_exception(self, request, exception):
        logger.error(f"Request failed: {request.method} {request.path}")
        logger.exception(exception)
        return None
