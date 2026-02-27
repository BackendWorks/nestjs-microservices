import { PrismaClient } from "@prisma/client";
import { PaginatedResult, QueryOptions } from "../interfaces/base.interface";

export async function findById<T>(
  client: PrismaClient,
  model: keyof PrismaClient,
  id: string,
): Promise<T | null> {
  const accessor = client[model] as any;
  return accessor.findFirst({
    where: { id, deletedAt: null, isDeleted: false },
  });
}

export async function findOne<T>(
  client: PrismaClient,
  model: keyof PrismaClient,
  filter: Record<string, unknown>,
): Promise<T | null> {
  const accessor = client[model] as any;
  return accessor.findFirst({
    where: { ...filter, deletedAt: null, isDeleted: false },
  });
}

export async function findMany<T>(
  client: PrismaClient,
  model: keyof PrismaClient,
  options: QueryOptions,
): Promise<PaginatedResult<T>> {
  const {
    page = 1,
    limit = 10,
    search,
    searchFields = [],
    sortBy = "createdAt",
    sortOrder = "desc",
    relations = [],
    customFilters = {},
  } = options;

  const safeLimit = Math.min(Number(limit), 100);
  const safePage = Math.max(Number(page), 1);
  const skip = (safePage - 1) * safeLimit;

  const where: Record<string, unknown> = {
    deletedAt: null,
    isDeleted: false,
    ...customFilters,
  };

  if (search && searchFields.length) {
    where["OR"] = searchFields.map((field) => ({
      [field]: { contains: search, mode: "insensitive" },
    }));
  }

  const include = buildInclude(relations);
  const accessor = client[model] as any;

  const [items, total] = await Promise.all([
    accessor.findMany({
      where,
      skip,
      take: safeLimit,
      orderBy: { [sortBy]: sortOrder },
      include: Object.keys(include).length ? include : undefined,
    }),
    accessor.count({ where }),
  ]);

  const totalPages = Math.ceil(total / safeLimit) || 1;

  return {
    items,
    meta: {
      page: safePage,
      limit: safeLimit,
      total,
      totalPages,
      hasNextPage: safePage < totalPages,
      hasPreviousPage: safePage > 1,
    },
  };
}

export async function createRecord<T>(
  client: PrismaClient,
  model: keyof PrismaClient,
  data: Record<string, unknown>,
): Promise<T> {
  const accessor = client[model] as any;
  return accessor.create({ data });
}

export async function updateRecord<T>(
  client: PrismaClient,
  model: keyof PrismaClient,
  id: string,
  data: Record<string, unknown>,
): Promise<T> {
  const accessor = client[model] as any;
  return accessor.update({ where: { id }, data });
}

export async function softDelete<T>(
  client: PrismaClient,
  model: keyof PrismaClient,
  id: string,
  deletedBy?: string,
): Promise<T> {
  const accessor = client[model] as any;
  return accessor.update({
    where: { id },
    data: {
      deletedAt: new Date(),
      isDeleted: true,
      ...(deletedBy ? { deletedBy } : {}),
    },
  });
}

export async function softDeleteMany(
  client: PrismaClient,
  model: keyof PrismaClient,
  ids: string[],
  deletedBy?: string,
): Promise<number> {
  const accessor = client[model] as any;
  const result = await accessor.updateMany({
    where: { id: { in: ids }, isDeleted: false },
    data: {
      deletedAt: new Date(),
      isDeleted: true,
      ...(deletedBy ? { deletedBy } : {}),
    },
  });
  return result.count;
}

export async function countRecords(
  client: PrismaClient,
  model: keyof PrismaClient,
  filters: Record<string, unknown> = {},
): Promise<number> {
  const accessor = client[model] as any;
  return accessor.count({
    where: { deletedAt: null, isDeleted: false, ...filters },
  });
}

function buildInclude(relations: string[]): Record<string, unknown> {
  const include: Record<string, unknown> = {};
  for (const relation of relations) {
    if (!relation.includes(".")) {
      include[relation] = true;
      continue;
    }
    const parts = relation.split(".");
    let curr = include;
    for (let i = 0; i < parts.length; i++) {
      const part = parts[i];
      if (i === parts.length - 1) {
        curr[part] = true;
      } else {
        if (!curr[part]) curr[part] = { include: {} };
        curr = (curr[part] as any).include;
      }
    }
  }
  return include;
}
