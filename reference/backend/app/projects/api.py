"""Projects API.

CRUD-конвенция (см. также app/profile/api.py):
  POST   /projects           201, body, returns ProjectRead
  GET    /projects            PaginatedResponse[ProjectRead]
  GET    /projects/{id}       ProjectRead | 404
  PATCH  /projects/{id}       ProjectRead | 404
  DELETE /projects/{id}       204 | 404
"""

from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.db import get_db
from app.profile.dependencies import get_current_user
from app.projects.service import get_project_by_id, list_projects
from app.shared._common import PaginatedResponse
from app.shared.enums import ProjectStatus
from app.shared.schemas import ProjectRead

router = APIRouter(prefix="/projects", tags=["projects"])


class ProjectCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)


class ProjectUpdate(BaseModel):
    title: str | None = Field(None, min_length=1, max_length=200)
    status: ProjectStatus | None = None


@router.post("", response_model=ProjectRead, status_code=201)
async def post_project(
    payload: ProjectCreate,
    db: AsyncSession = Depends(get_db),
    user=Depends(get_current_user),
) -> ProjectRead:
    raise NotImplementedError("WP-1.1 — Dev #1")


@router.get("", response_model=PaginatedResponse[ProjectRead])
async def get_all_projects(
    page: int = 1,
    page_size: int = 20,
    db: AsyncSession = Depends(get_db),
    user=Depends(get_current_user),
) -> PaginatedResponse[ProjectRead]:
    items, total = await list_projects(db, page=page, page_size=page_size)
    return PaginatedResponse[ProjectRead](
        items=[ProjectRead.model_validate(p) for p in items],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/{project_id}", response_model=ProjectRead)
async def get_project(
    project_id: UUID,
    db: AsyncSession = Depends(get_db),
    user=Depends(get_current_user),
) -> ProjectRead:
    project = await get_project_by_id(project_id, db)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return ProjectRead.model_validate(project)


@router.patch("/{project_id}", response_model=ProjectRead)
async def patch_project(
    project_id: UUID,
    payload: ProjectUpdate,
    db: AsyncSession = Depends(get_db),
    user=Depends(get_current_user),
) -> ProjectRead:
    raise NotImplementedError("WP-1.2 — Dev #1")


@router.delete("/{project_id}", status_code=204)
async def delete_project(
    project_id: UUID,
    db: AsyncSession = Depends(get_db),
    user=Depends(get_current_user),
) -> None:
    raise NotImplementedError("WP-1.3 — Dev #1")
