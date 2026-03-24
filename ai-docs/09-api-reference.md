# API Reference

## Base URL

All API endpoints are relative to the configured instance URL:

```
{instance_url}/api/v1
```

Example: `https://memos.example.com/api/v1`

## Authentication

All authenticated endpoints require a Bearer token:

```
Authorization: Bearer {access_token}
```

## Endpoints

### Authentication

#### Sign In (Credentials)

```
POST /api/v1/auth/signin
```

**Request:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "user": {
    "name": "string",
    "id": "int",
    "username": "string",
    "nickname": "string",
    "email": "string",
    "role": "string"
  },
  "accessToken": "string"
}
```

#### Sign In (Token)

```
POST /api/v1/auth/signin
```

**Request:**
```json
{
  "accessToken": "string"
}
```

**Response:**
```json
{
  "user": { ... },
  "accessToken": "string"
}
```

#### Sign Out

```
POST /api/v1/auth/signout
```

#### Get Current User

```
GET /api/v1/auth/me
```

**Response:**
```json
{
  "name": "string",
  "id": "int",
  "username": "string",
  "nickname": "string",
  "email": "string",
  "role": "string",
  "avatarUrl": "string"
}
```

---

### Memos

#### List Memos

```
GET /api/v1/memos
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `limit` | int | Page size (default: 20) |
| `offset` | int | Pagination offset |
| `filter` | string | Search filter |

**Response:**
```json
{
  "memos": [
    {
      "name": "memos/123",
      "uid": "uuid",
      "content": "string",
      "visibility": "PRIVATE|PROTECTED|PUBLIC",
      "pinned": false,
      "tags": ["tag1", "tag2"],
      "attachments": [...],
      "createdTime": "2024-01-01T00:00:00Z",
      "creator": "users/1"
    }
  ]
}
```

#### Get Memo

```
GET /api/v1/memos/{id}
```

**Response:** Memo object

#### Create Memo

```
POST /api/v1/memos
```

**Request:**
```json
{
  "content": "string",
  "visibility": "PRIVATE"
}
```

**Response:** Created memo object

#### Update Memo

```
PATCH /api/v1/memos/{id}
```

**Request:**
```json
{
  "content": "string",
  "visibility": "PUBLIC",
  "pinned": true
}
```

**Response:** Updated memo object

#### Delete Memo

```
DELETE /api/v1/memos/{id}
```

---

### Tags

#### Get Tag Statistics

```
GET /api/v1/memos:listTags
```

**Response:**
```json
{
  "tags": [
    {
      "name": "work",
      "count": 10
    }
  ]
}
```

---

### Attachments

#### Upload Attachment

```
POST /api/v1/attachments
Content-Type: multipart/form-data
```

**Request:**

| Field | Type |
|-------|------|
| `file` | File |
| `filename` | string |

**Response:**
```json
{
  "id": "int",
  "name": "string",
  "type": "string",
  "url": "string"
}
```

#### Set Memo Attachments

```
PATCH /api/v1/memos/{id}/attachments
```

**Request:**
```json
{
  "attachments": [
    { "id": 1, "name": "image.png" }
  ]
}
```

---

### Comments

#### List Comments

```
GET /api/v1/{memo_name}/comments
```

**Response:**
```json
{
  "comments": [
    {
      "name": "comments/1",
      "parentMemoName": "memos/123",
      "content": "string",
      "creator": "users/1",
      "createdTime": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### Create Comment

```
POST /api/v1/{memo_name}/comments
```

**Request:**
```json
{
  "content": "string"
}
```

---

### Shares

#### Create Share

```
POST /api/v1/memos/{id}/shares
```

**Request:**
```json
{
  "expiresAt": "2024-12-31T23:59:59Z"
}
```

**Response:**
```json
{
  "id": "abc123",
  "memo": "memos/123",
  "expiresAt": "2024-12-31T23:59:59Z"
}
```

#### Get Shared Memo

```
GET /api/v1/memos/share/{share_id}
```

**Response:** Memo object (no auth required)

#### List Memo Shares

```
GET /api/v1/memos/{id}/shares
```

#### Delete Share

```
DELETE /api/v1/memos/{id}/shares/{share_id}
```

---

## Error Responses

### Error Format

```json
{
  "error": "string",
  "message": "string",
  "details": {}
}
```

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 500 | Internal Server Error |

---

## Rate Limiting

The API may implement rate limiting. The client handles 429 responses with exponential backoff.

---

## Data Models

### Visibility

| Value | Description |
|-------|-------------|
| `PRIVATE` | Only visible to creator |
| `PROTECTED` | Visible to authenticated users |
| `PUBLIC` | Visible to everyone |

### RowStatus

| Value | Description |
|-------|-------------|
| `0` | Normal (active) |
| `1` | Archived |
| `2` | Deleted |

### Relation Types

| Value | Description |
|-------|-------------|
| `COMMENT` | Reference memo is a comment |
| `REFERENCE` | Reference memo is linked |