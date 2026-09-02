from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from .models import QRCode
from .serializers import QRCodeSerializer


@api_view(['POST'])
def create_qr(request):

    qr_type = request.data.get('type')
    content = request.data.get('content')

    if not qr_type or not content:
        return Response(
            {
                'error': 'Type and content are required'
            },
            status=status.HTTP_400_BAD_REQUEST
        )

    qr = QRCode.objects.create(
        qr_type=qr_type,
        content=content
    )

    serializer = QRCodeSerializer(qr)

    return Response(
        serializer.data,
        status=status.HTTP_201_CREATED
    )


@api_view(['GET'])
def qr_history(request):

    qrs = QRCode.objects.all().order_by('-created_at')

    serializer = QRCodeSerializer(
        qrs,
        many=True
    )

    return Response(serializer.data)


@api_view(['GET'])
def get_qr(request, pk):

    try:
        qr = QRCode.objects.get(pk=pk)
    except QRCode.DoesNotExist:
        return Response(
            {'error': 'QR not found'},
            status=status.HTTP_404_NOT_FOUND
        )

    serializer = QRCodeSerializer(qr)

    return Response(serializer.data)


@api_view(['DELETE'])
def delete_qr(request, pk):

    try:
        qr = QRCode.objects.get(pk=pk)
    except QRCode.DoesNotExist:
        return Response(
            {'error': 'QR not found'},
            status=status.HTTP_404_NOT_FOUND
        )

    qr.delete()

    return Response(
        {'message': 'QR deleted successfully'},
        status=status.HTTP_204_NO_CONTENT
    )
