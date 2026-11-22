-- Portal de Leiloes
-- Migration 005: Cadastro de documentos

BEGIN;

-- Tipos de documentos
CREATE TYPE public.tipo_documento AS ENUM (
    'rg_frente',
    'rg_verso',
    'cpf',
    'cnh_frente',
    'cnh_verso',
    'comprovante_residencia',
    'selfie',
    'certidao_matricula_junta',
    'certidao_criminal_federal',
    'certidao_criminal_estadual',
    'certidao_civel',
    'certidao_regularidade_fiscal',
    'comprovante_cnpj',
    'contrato_social',
    'documento_socio',
    'contrato_adesao'
);

-- Situacoes dos documentos
CREATE TYPE public.status_documento AS ENUM (
    'pendente',
    'em_analise',
    'aprovado',
    'reprovado',
    'expirado',
    'substituido'
);

-- Tabela de controle dos documentos
CREATE TABLE public.documentos (
    id UUID PRIMARY KEY
        DEFAULT gen_random_uuid(),

    perfil_id UUID NOT NULL
        REFERENCES public.perfis(id)
        ON DELETE CASCADE,

    tipo public.tipo_documento NOT NULL,

    nome_arquivo VARCHAR(255) NOT NULL,

    caminho_arquivo TEXT NOT NULL UNIQUE,

    mime_type VARCHAR(100) NOT NULL,

    tamanho_bytes BIGINT NOT NULL,

    status public.status_documento NOT NULL
        DEFAULT 'pendente',

    data_emissao DATE,

    data_validade DATE,

    motivo_reprovacao TEXT,

    analisado_por UUID
        REFERENCES public.perfis(id)
        ON DELETE SET NULL,

    analisado_em TIMESTAMPTZ,

    criado_em TIMESTAMPTZ NOT NULL
        DEFAULT NOW(),

    atualizado_em TIMESTAMPTZ NOT NULL
        DEFAULT NOW(),

    CONSTRAINT documentos_tamanho_valido
        CHECK (
            tamanho_bytes > 0
            AND tamanho_bytes <= 10485760
        ),

    CONSTRAINT documentos_mime_valido
        CHECK (
            mime_type IN (
                'application/pdf',
                'image/jpeg',
                'image/png'
            )
        ),

    CONSTRAINT documentos_caminho_valido
        CHECK (
            split_part(caminho_arquivo, '/', 1)
                = perfil_id::TEXT
            AND split_part(caminho_arquivo, '/', 2)
                <> ''
        ),

    CONSTRAINT documentos_datas_validas
        CHECK (
            data_emissao IS NULL
            OR data_validade IS NULL
            OR data_validade >= data_emissao
        ),

    CONSTRAINT documentos_reprovacao_motivo
        CHECK (
            status <> 'reprovado'
            OR (
                motivo_reprovacao IS NOT NULL
                AND CHAR_LENGTH(
                    TRIM(motivo_reprovacao)
                ) > 0
            )
        )
);

-- Indices para consultas
CREATE INDEX documentos_perfil_idx
ON public.documentos (perfil_id);

CREATE INDEX documentos_status_idx
ON public.documentos (status);

CREATE INDEX documentos_tipo_idx
ON public.documentos (tipo);

-- Ativa seguranca por linha
ALTER TABLE public.documentos
ENABLE ROW LEVEL SECURITY;

-- Remove permissoes diretas dos clientes
REVOKE ALL ON TABLE public.documentos
FROM PUBLIC, anon, authenticated;

-- Permite consulta por usuarios autenticados
GRANT SELECT ON TABLE public.documentos
TO authenticated;

-- Cada usuario consulta somente seus documentos
CREATE POLICY "Consultar proprios documentos"
ON public.documentos
FOR SELECT
TO authenticated
USING (
    (SELECT auth.uid()) = perfil_id
);

-- Atualizacao automatica de data
CREATE TRIGGER trg_atualizar_documento
BEFORE UPDATE ON public.documentos
FOR EACH ROW
EXECUTE FUNCTION public.atualizar_data_perfil();

COMMIT;