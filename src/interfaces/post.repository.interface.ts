import { Post } from "@prisma/client";
import { PaginatedResult, QueryOptions } from "./base.interface";

export type { Post };

export interface CreatePostInput {
  title: string;
  content: string;
  images?: string[];
  createdBy: string;
}

export interface UpdatePostInput {
  title?: string;
  content?: string;
  images?: string[];
  updatedBy?: string;
}

export interface IPostRepository {
  findById(id: string): Promise<Post | null>;
  findOne(filter: Partial<Post>): Promise<Post | null>;
  findMany(options: QueryOptions): Promise<PaginatedResult<Post>>;
  create(data: CreatePostInput): Promise<Post>;
  update(id: string, data: UpdatePostInput): Promise<Post>;
  softDelete(id: string, deletedBy?: string): Promise<Post>;
  softDeleteMany(ids: string[], deletedBy?: string): Promise<number>;
  count(filters?: Partial<Post>): Promise<number>;
}
