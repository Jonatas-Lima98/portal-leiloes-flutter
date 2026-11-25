-- Portal de Leiloes
-- Migration 008: Politicas de seguranca do Storage

BEGIN;

-- Permite enviar documentos para a propria pasta
CREATE POLICY "Enviar proprios documentos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'documentos-usuarios'
    AND (storage.foldername(name))[1]
        = (SELECT auth.uid())::TEXT
);

-- Permite consultar somente os proprios arquivos
CREATE POLICY "Consultar proprios arquivos"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'documentos-usuarios'
    AND (storage.foldername(name))[1]
        = (SELECT auth.uid())::TEXT
);

-- Restringe o acesso aos documentos
CREATE POLICY "Restringir acesso aos documentos"
ON storage.objects
AS RESTRICTIVE
FOR SELECT
TO PUBLIC
USING (
    bucket_id <> 'documentos-usuarios'
    OR (
        (SELECT auth.uid()) IS NOT NULL
        AND (storage.foldername(name))[1]
            = (SELECT auth.uid())::TEXT
    )
);

-- Restringe o envio de documentos
CREATE POLICY "Restringir envio de documentos"
ON storage.objects
AS RESTRICTIVE
FOR INSERT
TO PUBLIC
WITH CHECK (
    bucket_id <> 'documentos-usuarios'
    OR (
        (SELECT auth.uid()) IS NOT NULL
        AND (storage.foldername(name))[1]
            = (SELECT auth.uid())::TEXT
    )
);

-- Bloqueia alteracoes diretas nos documentos
CREATE POLICY "Bloquear alteracao de documentos"
ON storage.objects
AS RESTRICTIVE
FOR UPDATE
TO PUBLIC
USING (
    bucket_id <> 'documentos-usuarios'
)
WITH CHECK (
    bucket_id <> 'documentos-usuarios'
);

-- Bloqueia exclusoes diretas dos documentos
CREATE POLICY "Bloquear exclusao de documentos"
ON storage.objects
AS RESTRICTIVE
FOR DELETE
TO PUBLIC
USING (
    bucket_id <> 'documentos-usuarios'
);

COMMIT;