# 🖥️ modules-ec2-tmp

**Repositorio:** `ISC-2026-Martinez-Ourthe-Cabale/modules-ec2-tmp`
**Lenguaje:** HCL (Terraform)

## Descripción

Este módulo aprovisiona una instancia EC2 que **inicializa la base de datos de forma idempotente** y completa las URLs de imágenes de los productos. Se ejecuta como parte de cada `terraform apply`, vía `user_data`.

### Flujo del `user_data`

1. Instala `mariadb105` (cliente MySQL) y `awscli`.
2. Descarga `db-settings.sql` desde `s3://<bucket_name>/db-settings/db-settings.sql`.
3. Espera (con reintentos) a que la base de datos RDS responda.
4. **Chequea si la base ya está poblada**, buscando la tabla `admin` (`SHOW TABLES LIKE 'admin'`).
   - Si la tabla **ya existe** → no hace nada más (evita el error de `CREATE TABLE` duplicado en reaplicaciones).
   - Si **no existe** →
     a. Ejecuta `db-settings.sql` contra la base (crea tablas y carga los datos semilla).
     b. Corre un `UPDATE products SET images = ...` que arma el array serializado de PHP (`a:1:{i:0;s:N:"url";}`) que espera la aplicación, usando `images_base_url` (el bucket público de imágenes de `storage-backup`) más el nombre de archivo que ya está en cada fila.

## Por qué EC2 y no Lambda

La base de datos vive en una subnet privada solo accesible desde el Security Group de EC2. Esta instancia reutiliza ese mismo SG y el cliente `mysql` ya instalado, sin necesitar VPC config de Lambda ni vendorear un driver de MySQL.

## Recursos Creados

| Recurso AWS    | Descripción                                                                |
| --------------- | ----------------------------------------------------------------------------- |
| `aws_instance` | Instancia EC2 (`db-init-job`) que ejecuta el `user_data` descripto arriba   |

## Variables de Entrada

| Variable                | Tipo           | Default     | Descripción                                                          |
| ------------------------ | -------------- | ----------- | ----------------------------------------------------------------------- |
| `private_subnet_ids`    | `list(string)` | —           | Subnets privadas APP; se usa la primera (`[0]`) para la instancia      |
| `ec2_security_group_id` | `string`       | —           | Security Group de EC2, con acceso permitido hacia RDS                 |
| `instance_type`         | `string`       | `"t3.micro"` | Tipo de instancia                                                      |
| `ami`                   | `string`       | —           | AMI a utilizar                                                        |
| `db_host`               | `string`       | —           | Endpoint/host de la base de datos RDS                                 |
| `db_name`               | `string`       | —           | Nombre de la base de datos                                            |
| `db_username`           | `string`       | —           | Usuario de la base de datos                                           |
| `db_password`           | `string`       | —           | Contraseña de la base de datos                                        |
| `db_port`               | `string`       | —           | Puerto de la base de datos                                            |
| `bucket_name`           | `string`       | —           | Bucket S3 donde está `db-settings.sql`                                |
| `images_base_url`       | `string`       | —           | URL base HTTPS del bucket público de imágenes (output de `storage-backup`) |

## Ejemplo de Uso

```hcl
module "ec2-tmp" {
  source = "git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/modules-ec2-tmp.git"

  db_host               = module.database.db_address
  db_name               = var.db_name
  db_port               = var.db_port
  db_username           = var.db_username
  db_password           = var.db_password
  ami                   = var.ami
  private_subnet_ids    = module.networking.private_app_subnet_ids
  ec2_security_group_id = module.security_groups.ec2_sg_id
  bucket_name           = var.bucket_name
  images_base_url       = module.db_storage.images_base_url

  depends_on = [
    module.db_storage
  ]
}
```

## Consideraciones

> **Reposblar desde cero:** si ya aplicaste este módulo antes de que existiera el fix de imágenes, la tabla `admin` ya existe y el bloque entero (incluido el `UPDATE` de imágenes) se va a seguir saltando. Para que corra, hay que repoblar la base desde cero o ejecutar el `UPDATE` manualmente.
