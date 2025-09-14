# データモデル: 書籍管理システム

**日付**: 2025-09-14
**バージョン**: 1.0.0

## エンティティ定義

### 1. Book（書籍）

**説明**: 書籍の基本情報を管理するエンティティ

| フィールド | 型 | 制約 | 説明 |
|-----------|-----|------|------|
| id | UUID | PK, NOT NULL | 書籍の一意識別子 |
| title | VARCHAR(255) | NOT NULL | 書籍タイトル |
| price | DECIMAL(10,2) | NOT NULL, >= 0 | 価格（円） |
| publishStatus | ENUM | NOT NULL | 出版状況（UNPUBLISHED, PUBLISHED） |
| createdAt | TIMESTAMP | NOT NULL | 作成日時 |
| updatedAt | TIMESTAMP | NOT NULL | 更新日時 |

**ビジネスルール**:
- 価格は0以上でなければならない
- 出版済み（PUBLISHED）から未出版（UNPUBLISHED）への変更は不可
- 書籍は最低1人の著者を持たなければならない

### 2. Author（著者）

**説明**: 著者の基本情報を管理するエンティティ

| フィールド | 型 | 制約 | 説明 |
|-----------|-----|------|------|
| id | UUID | PK, NOT NULL | 著者の一意識別子 |
| name | VARCHAR(100) | NOT NULL | 著者名 |
| birthDate | DATE | NOT NULL | 生年月日 |
| createdAt | TIMESTAMP | NOT NULL | 作成日時 |
| updatedAt | TIMESTAMP | NOT NULL | 更新日時 |

**ビジネスルール**:
- 生年月日は現在日付より過去でなければならない
- 同姓同名の著者が存在可能（一意性制約なし）

### 3. BookAuthor（書籍-著者関連）

**説明**: 書籍と著者の多対多の関係を管理する中間テーブル

| フィールド | 型 | 制約 | 説明 |
|-----------|-----|------|------|
| bookId | UUID | FK, NOT NULL | 書籍ID |
| authorId | UUID | FK, NOT NULL | 著者ID |
| createdAt | TIMESTAMP | NOT NULL | 作成日時 |

**制約**:
- PRIMARY KEY (bookId, authorId)
- FOREIGN KEY (bookId) REFERENCES Book(id)
- FOREIGN KEY (authorId) REFERENCES Author(id)

## 値オブジェクト

### PublishStatus（出版状況）

```kotlin
enum class PublishStatus {
    UNPUBLISHED,  // 未出版
    PUBLISHED     // 出版済み
}
```

**状態遷移**:
```
UNPUBLISHED → PUBLISHED ✓（許可）
PUBLISHED → UNPUBLISHED ✗（禁止）
```

### Price（価格）

```kotlin
@JvmInline
value class Price(val value: BigDecimal) {
    init {
        require(value >= BigDecimal.ZERO) {
            "価格は0以上でなければなりません"
        }
    }
}
```

### BookTitle（書籍タイトル）

```kotlin
@JvmInline
value class BookTitle(val value: String) {
    init {
        require(value.isNotBlank()) {
            "タイトルは空にできません"
        }
        require(value.length <= 255) {
            "タイトルは255文字以内でなければなりません"
        }
    }
}
```

### AuthorName（著者名）

```kotlin
@JvmInline
value class AuthorName(val value: String) {
    init {
        require(value.isNotBlank()) {
            "著者名は空にできません"
        }
        require(value.length <= 100) {
            "著者名は100文字以内でなければなりません"
        }
    }
}
```

## データベーススキーマ

### テーブル作成SQL（PostgreSQL）

```sql
-- 書籍テーブル
CREATE TABLE books (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    publish_status VARCHAR(20) NOT NULL CHECK (publish_status IN ('UNPUBLISHED', 'PUBLISHED')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 著者テーブル
CREATE TABLE authors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL CHECK (birth_date < CURRENT_DATE),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 書籍-著者関連テーブル
CREATE TABLE book_authors (
    book_id UUID NOT NULL REFERENCES books(id),
    author_id UUID NOT NULL REFERENCES authors(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (book_id, author_id)
);

-- インデックス
CREATE INDEX idx_books_publish_status ON books(publish_status);
CREATE INDEX idx_authors_name ON authors(name);
CREATE INDEX idx_book_authors_author_id ON book_authors(author_id);
```

## リレーションシップ

```
Book (1) ---- (*) BookAuthor (*) ---- (1) Author
```

- 1つの書籍は複数の著者を持つことができる
- 1人の著者は複数の書籍を執筆できる
- 書籍は最低1人の著者を持たなければならない（アプリケーション層で保証）

## 集約境界

### Book集約
- ルートエンティティ: Book
- 関連: BookAuthor（書籍側から管理）
- 責務: 書籍情報の管理、出版状況の制御、著者との関連付け

### Author集約
- ルートエンティティ: Author
- 責務: 著者情報の管理

## トランザクション境界

- 書籍の登録/更新時は、BookとBookAuthorを同一トランザクションで処理
- 著者の登録/更新は独立したトランザクション
- 著者に紐づく書籍の取得は読み取り専用トランザクション