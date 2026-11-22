-- Portal de Leiloes
-- Migration 007: Storage privado de documentos

BEGIN;

INSERT INTO storage.buckets (
    id,
    name,
    public,
    file_size_limit,
    allowed_mime_types
)
VALUES (
    'documentos-usuarios',
    'documentos-usuarios',
    FALSE,
    10485760,
    ARRAY[
        'application/pdf',
        'image/jpeg',
        'image/png'
    ]::TEXT[]
);

COMMIT;