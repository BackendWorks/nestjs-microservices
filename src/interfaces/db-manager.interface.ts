import { IPostRepository } from "./post.repository.interface";

export interface IPostDbManager {
  postRepository: IPostRepository;
  disconnect(): Promise<void>;
}
