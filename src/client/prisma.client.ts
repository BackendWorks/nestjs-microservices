import { PrismaClient } from "@prisma/client";
import { IPostDbManager } from "../interfaces/db-manager.interface";
import { IPostRepository } from "../interfaces/post.repository.interface";
import { PostRepository } from "../repositories/post.repository";

class PostDbManager implements IPostDbManager {
  readonly postRepository: IPostRepository;
  private readonly prisma: PrismaClient;

  constructor(databaseUrl: string) {
    this.prisma = new PrismaClient({
      datasources: { db: { url: databaseUrl } },
      log:
        process.env.NODE_ENV === "development"
          ? ["query", "error", "warn"]
          : ["error"],
    });
    this.postRepository = new PostRepository(this.prisma);
  }

  async disconnect(): Promise<void> {
    await this.prisma.$disconnect();
  }
}

let instance: PostDbManager | null = null;

/**
 * Returns a singleton IPostDbManager.
 * Call once at application startup and reuse the returned instance.
 */
export function createPostDbManager(databaseUrl: string): IPostDbManager {
  if (!instance) {
    instance = new PostDbManager(databaseUrl);
  }
  return instance;
}

/**
 * Resets the singleton — useful in tests.
 */
export function resetPostDbManager(): void {
  instance = null;
}
