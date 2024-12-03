from rest_framework.decorators import api_view
from rest_framework.response import Response
import logging

logger = logging.getLogger('django')

@api_view(['GET'])
def test_connection(request):
    logger.info("Test connection endpoint hit!")
    return Response({
        "status": "success",
        "message": "Backend is connected and working!",
        "timestamp": "Connection successful"
    })
