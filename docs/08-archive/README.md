# 📦 Arquivo Histórico & Especificações Deprecadas

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Módulo:** Governance & Archival  
**Versão:** 1.0.0  

---

## 1. Finalidade do Diretório

A pasta `08-archive/` destina-se a armazenar rascunhos históricos, decisões de arquitetura substituídas (ADRs tornadas *Deprecated* ou *Superseded*), notas de versão legadas e especificações de modelos que deixaram de ser adotados no projeto.

O objetivo é manter o histórico de evolução técnica auditável e transparente, sem poluir a documentação ativa mantida nas pastas `00` a `07`.

---

## 2. Política de Arquivamento e Deprecação

Para mover ou arquivar um documento neste diretório, o mantenedor deve seguir as diretrizes:

1. **Inclusão de Banner de Deprecação:** Todo arquivo movido para esta pasta deve possuir no topo do documento o aviso em destaque:
   ```markdown
   > ⚠️ **DOCUMENTO ARQUIVADO / OBSOLETO**  
   > **Status:** Deprecated (Substituído pela especificação v1.0.0)  
   > **Motivo:** [Descrever sucintamente o motivo da substituição]
Atualização do Índice do Arquivo: O arquivo arquivado deve ser catalogado no repositório com a data da obsolescência e o link para o novo documento ativo correspondente.3. Catálogo de Documentos ArquivadosDocumento ArquivadoData de ArquivamentoSubstituído porMotivo da Alteraçãochangelog-v0.md2026-09-15/docs/README.mdTransição do modelo inicial em planilha monolítica para a arquitetura relacional PostgreSQL.