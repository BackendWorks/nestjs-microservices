import { PrismaClient, Post } from "@prisma/client";
import {
  IPostRepository,
  CreatePostInput,
  UpdatePostInput,
} from "../interfaces/post.repository.interface";
import { PaginatedResult, QueryOptions } from "../interfaces/base.interface";
import {
  findById,
  findOne,
  findMany,
  createRecord,
  updateRecord,
  softDelete,
  softDeleteMany,
  countRecords,
} from "../operations/base.operations";

export class PostRepository implements IPostRepository {
  constructor(private readonly client: PrismaClient) {}

  async findById(id: string): Promise<Post | null> {
    return findById<Post>(this.client, "post", id);
  }

  async findOne(filter: Partial<Post>): Promise<Post | null> {
    return findOne<Post>(
      this.client,
      "post",
      filter as Record<string, unknown>,
    );
  }

  async findMany(options: QueryOptions): Promise<PaginatedResult<Post>> {
    return findMany<Post>(this.client, "post", {
      ...options,
      searchFields: options.searchFields ?? ["title", "content"],
    });
  }

  async create(data: CreatePostInput): Promise<Post> {
    return createRecord<Post>(
      this.client,
      "post",
      data as Record<string, unknown>,
    );
  }

  async update(id: string, data: UpdatePostInput): Promise<Post> {
    return updateRecord<Post>(
      this.client,
      "post",
      id,
      data as Record<string, unknown>,
    );
  }

  async softDelete(id: string, deletedBy?: string): Promise<Post> {
    return softDelete<Post>(this.client, "post", id, deletedBy);
  }

  async softDeleteMany(ids: string[], deletedBy?: string): Promise<number> {
    return softDeleteMany(this.client, "post", ids, deletedBy);
  }

  async count(filters?: Partial<Post>): Promise<number> {
    return countRecords(
      this.client,
      "post",
      filters as Record<string, unknown>,
    );
  }
}
