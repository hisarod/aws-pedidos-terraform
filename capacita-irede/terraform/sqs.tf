# ==========================================
# Fila SQS para processar pedidos
# ==========================================

resource "aws_sqs_queue" "pedidos" {
  name = "pedidos-a-processar"

  tags = {
    Name    = "pedidos-a-processar"
    Projeto = var.project_name
  }
}