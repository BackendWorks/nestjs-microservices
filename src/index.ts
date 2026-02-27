// Public API — only import from this file, never from internal paths
export {
  createPostDbManager,
  resetPostDbManager,
} from "./client/prisma.client";
export type { IPostDbManager } from "./interfaces/db-manager.interface";
export type {
  IPostRepository,
  CreatePostInput,
  UpdatePostInput,
} from "./interfaces/post.repository.interface";
export type { Post } from "./interfaces/post.repository.interface";
export type {
  PaginatedResult,
  QueryOptions,
} from "./interfaces/base.interface";
