# SDK and Integration Examples

This document provides comprehensive examples for integrating with the Blancakan API using various programming languages and frameworks.

## Table of Contents

- [JavaScript/TypeScript SDK](#javascripttypescript-sdk)
- [Python SDK](#python-sdk)
- [Ruby SDK](#ruby-sdk)
- [PHP SDK](#php-sdk)
- [React Integration](#react-integration)
- [Vue.js Integration](#vuejs-integration)
- [Flutter/Dart Integration](#flutterdart-integration)
- [Webhook Integration](#webhook-integration)

## JavaScript/TypeScript SDK

### Complete SDK Implementation

```typescript
// blancakan-api-client.ts
import axios, { AxiosInstance, AxiosResponse } from "axios";

export interface ApiResponse<T = any> {
  status: "success" | "error";
  message: string;
  data?: T;
  errors?: Array<{
    field: string;
    code: string;
    message: string;
  }>;
  meta?: {
    current_page: number;
    total_pages: number;
    total_count: number;
    per_page: number;
    next_page?: number;
    prev_page?: number;
  };
}

export interface User {
  id: string;
  email: string;
  role?: {
    id: string;
    name: string;
  };
  created_at: string;
  updated_at: string;
}

export interface Category {
  _id: string;
  name: string;
  description: string;
  parent_id?: string;
  status: boolean;
  created_at: string;
  updated_at: string;
}

export interface Event {
  _id: string;
  title: string;
  description: string;
  start_date: string;
  end_date: string;
  location: string;
  status: "draft" | "published" | "cancelled" | "completed";
  organizer_id: string;
  event_type_id: string;
  category_ids: string[];
  image_url?: string;
  created_at: string;
  updated_at: string;
}

export interface EventType {
  _id: string;
  name: string;
  description: string;
  status: boolean;
  created_at: string;
  updated_at: string;
}

export interface AuthTokens {
  user: User;
  token: string;
}

export interface CreateEventData {
  title: string;
  description: string;
  start_date: string;
  end_date: string;
  location: string;
  event_type_id: string;
  category_ids: string[];
  image?: File;
}

export class BlancakanApiError extends Error {
  constructor(message: string, public status?: number, public errors?: any[]) {
    super(message);
    this.name = "BlancakanApiError";
  }
}

export class BlancakanApiClient {
  private client: AxiosInstance;
  private token: string | null = null;

  constructor(baseURL: string = "http://localhost:3000") {
    this.client = axios.create({
      baseURL,
      timeout: 10000,
      headers: {
        "Content-Type": "application/json",
      },
    });

    // Request interceptor to add auth token
    this.client.interceptors.request.use(
      (config) => {
        if (this.token) {
          config.headers.Authorization = `Bearer ${this.token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor to handle errors
    this.client.interceptors.response.use(
      (response) => response,
      (error) => {
        const message = error.response?.data?.message || error.message;
        const status = error.response?.status;
        const errors = error.response?.data?.errors;

        throw new BlancakanApiError(message, status, errors);
      }
    );
  }

  // Authentication Methods
  async register(
    email: string,
    password: string,
    passwordConfirmation: string
  ): Promise<AuthTokens> {
    const response: AxiosResponse<ApiResponse<AuthTokens>> =
      await this.client.post("/auth", {
        email,
        password,
        password_confirmation: passwordConfirmation,
      });

    const { data: authData } = response.data;
    if (authData?.token) {
      this.setToken(authData.token);
    }

    return authData!;
  }

  async signIn(email: string, password: string): Promise<AuthTokens> {
    const response: AxiosResponse<ApiResponse<AuthTokens>> =
      await this.client.post("/auth/sign_in", {
        email,
        password,
      });

    const { data: authData } = response.data;
    if (authData?.token) {
      this.setToken(authData.token);
    }

    return authData!;
  }

  async signOut(): Promise<void> {
    await this.client.delete("/auth/sign_out");
    this.clearToken();
  }

  setToken(token: string): void {
    this.token = token;
    // Store in localStorage for persistence
    if (typeof localStorage !== "undefined") {
      localStorage.setItem("blancakan_token", token);
    }
  }

  clearToken(): void {
    this.token = null;
    if (typeof localStorage !== "undefined") {
      localStorage.removeItem("blancakan_token");
    }
  }

  loadTokenFromStorage(): void {
    if (typeof localStorage !== "undefined") {
      const token = localStorage.getItem("blancakan_token");
      if (token) {
        this.token = token;
      }
    }
  }

  // Categories Methods
  async getCategories(): Promise<Category[]> {
    const response: AxiosResponse<ApiResponse<Category[]>> =
      await this.client.get("/api/v1/admin/categories");
    return response.data.data!;
  }

  async getCategory(id: string): Promise<Category> {
    const response: AxiosResponse<ApiResponse<Category>> =
      await this.client.get(`/api/v1/admin/categories/${id}`);
    return response.data.data!;
  }

  async createCategory(
    name: string,
    description: string,
    parentId?: string
  ): Promise<Category> {
    const data: any = { name, description };
    if (parentId) {
      data.parent_id = parentId;
    }

    const response: AxiosResponse<ApiResponse<Category>> =
      await this.client.post("/api/v1/admin/categories", data);
    return response.data.data!;
  }

  async updateCategory(
    id: string,
    name: string,
    description: string
  ): Promise<Category> {
    const response: AxiosResponse<ApiResponse<Category>> =
      await this.client.put(`/api/v1/admin/categories/${id}`, {
        name,
        description,
      });
    return response.data.data!;
  }

  async deleteCategory(id: string): Promise<void> {
    await this.client.delete(`/api/v1/admin/categories/${id}`);
  }

  // Events Methods
  async getEvents(params?: {
    page?: number;
    per_page?: number;
    status?: string;
    category_id?: string;
    search?: string;
  }): Promise<{ events: Event[]; meta: any }> {
    const response: AxiosResponse<ApiResponse<Event[]>> = await this.client.get(
      "/api/v1/admin/events",
      { params }
    );
    return {
      events: response.data.data!,
      meta: response.data.meta!,
    };
  }

  async getEvent(id: string): Promise<Event> {
    const response: AxiosResponse<ApiResponse<Event>> = await this.client.get(
      `/api/v1/admin/events/${id}`
    );
    return response.data.data!;
  }

  async createEvent(eventData: CreateEventData): Promise<Event> {
    const formData = new FormData();

    Object.keys(eventData).forEach((key) => {
      if (key === "image" && eventData.image) {
        formData.append("image", eventData.image);
      } else if (key === "category_ids") {
        eventData.category_ids.forEach((categoryId) => {
          formData.append("category_ids[]", categoryId);
        });
      } else {
        formData.append(key, (eventData as any)[key]);
      }
    });

    const response: AxiosResponse<ApiResponse<Event>> = await this.client.post(
      "/api/v1/admin/events",
      formData,
      {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      }
    );

    return response.data.data!;
  }

  async updateEvent(
    id: string,
    eventData: Partial<CreateEventData>
  ): Promise<Event> {
    const formData = new FormData();

    Object.keys(eventData).forEach((key) => {
      if (key === "image" && eventData.image) {
        formData.append("image", eventData.image);
      } else if (key === "category_ids" && eventData.category_ids) {
        eventData.category_ids.forEach((categoryId) => {
          formData.append("category_ids[]", categoryId);
        });
      } else if ((eventData as any)[key] !== undefined) {
        formData.append(key, (eventData as any)[key]);
      }
    });

    const response: AxiosResponse<ApiResponse<Event>> = await this.client.put(
      `/api/v1/admin/events/${id}`,
      formData,
      {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      }
    );

    return response.data.data!;
  }

  async deleteEvent(id: string): Promise<void> {
    await this.client.delete(`/api/v1/admin/events/${id}`);
  }

  // Event Types Methods
  async getEventTypes(): Promise<EventType[]> {
    const response: AxiosResponse<ApiResponse<EventType[]>> =
      await this.client.get("/api/v1/admin/event_types");
    return response.data.data!;
  }

  // Users Methods
  async getUsers(params?: {
    page?: number;
    per_page?: number;
    search?: string;
  }): Promise<{ users: User[]; meta: any }> {
    const response: AxiosResponse<ApiResponse<User[]>> = await this.client.get(
      "/api/v1/admin/users",
      { params }
    );
    return {
      users: response.data.data!,
      meta: response.data.meta!,
    };
  }
}

// Usage Example
export const createBlancakanClient = (baseURL?: string) => {
  const client = new BlancakanApiClient(baseURL);
  client.loadTokenFromStorage(); // Load token from localStorage if available
  return client;
};
```

### Usage Examples

```typescript
// examples.ts
import {
  createBlancakanClient,
  BlancakanApiError,
} from "./blancakan-api-client";

const api = createBlancakanClient("http://localhost:3000");

async function authenticationExample() {
  try {
    // Register
    const registerResult = await api.register(
      "user@example.com",
      "password123",
      "password123"
    );
    console.log("User registered:", registerResult.user.email);

    // Sign in
    const signInResult = await api.signIn("user@example.com", "password123");
    console.log("User signed in:", signInResult.user.email);
    console.log("Token:", signInResult.token);
  } catch (error) {
    if (error instanceof BlancakanApiError) {
      console.error("API Error:", error.message);
      console.error("Status:", error.status);
      console.error("Validation errors:", error.errors);
    }
  }
}

async function categoriesExample() {
  try {
    // Create category
    const category = await api.createCategory(
      "Technology",
      "Technology related events"
    );
    console.log("Category created:", category.name);

    // Get all categories
    const categories = await api.getCategories();
    console.log("Total categories:", categories.length);

    // Update category
    const updatedCategory = await api.updateCategory(
      category._id,
      "Advanced Technology",
      "Advanced technology events"
    );
    console.log("Category updated:", updatedCategory.name);
  } catch (error) {
    console.error("Categories error:", error);
  }
}

async function eventsExample() {
  try {
    // Get events with pagination
    const { events, meta } = await api.getEvents({
      page: 1,
      per_page: 10,
      status: "published",
    });

    console.log(`Found ${events.length} events`);
    console.log(`Page ${meta.current_page} of ${meta.total_pages}`);

    // Create event with image
    const imageFile = new File([""], "event-image.jpg", { type: "image/jpeg" });

    const eventData = {
      title: "Tech Conference 2024",
      description: "Annual technology conference",
      start_date: "2024-03-15T09:00:00Z",
      end_date: "2024-03-17T18:00:00Z",
      location: "Convention Center",
      event_type_id: "your-event-type-id",
      category_ids: ["your-category-id"],
      image: imageFile,
    };

    const newEvent = await api.createEvent(eventData);
    console.log("Event created:", newEvent.title);
  } catch (error) {
    console.error("Events error:", error);
  }
}
```

## Python SDK

```python
# blancakan_api_client.py
import requests
import json
from typing import Optional, Dict, Any, List, Union
from dataclasses import dataclass
from datetime import datetime

@dataclass
class User:
    id: str
    email: str
    role: Optional[Dict[str, str]] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

@dataclass
class Category:
    _id: str
    name: str
    description: str
    status: bool
    created_at: str
    updated_at: str
    parent_id: Optional[str] = None

@dataclass
class Event:
    _id: str
    title: str
    description: str
    start_date: str
    end_date: str
    location: str
    status: str
    organizer_id: str
    event_type_id: str
    category_ids: List[str]
    created_at: str
    updated_at: str
    image_url: Optional[str] = None

class BlancakanApiError(Exception):
    def __init__(self, message: str, status_code: Optional[int] = None, errors: Optional[List] = None):
        super().__init__(message)
        self.status_code = status_code
        self.errors = errors or []

class BlancakanApiClient:
    def __init__(self, base_url: str = "http://localhost:3000"):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.timeout = 10
        self.token: Optional[str] = None

    def _make_request(self, method: str, endpoint: str, **kwargs) -> Dict[str, Any]:
        url = f"{self.base_url}{endpoint}"

        if self.token:
            self.session.headers.update({'Authorization': f'Bearer {self.token}'})

        try:
            response = self.session.request(method, url, **kwargs)
            response.raise_for_status()

            # Handle empty responses (like DELETE operations)
            if response.status_code == 204:
                return {"status": "success", "message": "Operation completed"}

            return response.json()

        except requests.exceptions.HTTPError as e:
            try:
                error_data = response.json()
                raise BlancakanApiError(
                    error_data.get('message', str(e)),
                    response.status_code,
                    error_data.get('errors', [])
                )
            except ValueError:
                raise BlancakanApiError(str(e), response.status_code)
        except requests.exceptions.RequestException as e:
            raise BlancakanApiError(str(e))

    # Authentication Methods
    def register(self, email: str, password: str, password_confirmation: str) -> Dict[str, Any]:
        data = {
            'email': email,
            'password': password,
            'password_confirmation': password_confirmation
        }

        response = self._make_request('POST', '/auth', json=data)

        if 'data' in response and 'token' in response['data']:
            self.set_token(response['data']['token'])

        return response['data']

    def sign_in(self, email: str, password: str) -> Dict[str, Any]:
        data = {'email': email, 'password': password}
        response = self._make_request('POST', '/auth/sign_in', json=data)

        if 'data' in response and 'token' in response['data']:
            self.set_token(response['data']['token'])

        return response['data']

    def sign_out(self) -> None:
        self._make_request('DELETE', '/auth/sign_out')
        self.clear_token()

    def set_token(self, token: str) -> None:
        self.token = token
        self.session.headers.update({'Authorization': f'Bearer {token}'})

    def clear_token(self) -> None:
        self.token = None
        if 'Authorization' in self.session.headers:
            del self.session.headers['Authorization']

    # Categories Methods
    def get_categories(self) -> List[Category]:
        response = self._make_request('GET', '/api/v1/admin/categories')
        return [Category(**item) for item in response['data']]

    def get_category(self, category_id: str) -> Category:
        response = self._make_request('GET', f'/api/v1/admin/categories/{category_id}')
        return Category(**response['data'])

    def create_category(self, name: str, description: str, parent_id: Optional[str] = None) -> Category:
        data = {'name': name, 'description': description}
        if parent_id:
            data['parent_id'] = parent_id

        response = self._make_request('POST', '/api/v1/admin/categories', json=data)
        return Category(**response['data'])

    def update_category(self, category_id: str, name: str, description: str) -> Category:
        data = {'name': name, 'description': description}
        response = self._make_request('PUT', f'/api/v1/admin/categories/{category_id}', json=data)
        return Category(**response['data'])

    def delete_category(self, category_id: str) -> None:
        self._make_request('DELETE', f'/api/v1/admin/categories/{category_id}')

    # Events Methods
    def get_events(self, page: int = 1, per_page: int = 20, **filters) -> Dict[str, Any]:
        params = {'page': page, 'per_page': per_page, **filters}
        response = self._make_request('GET', '/api/v1/admin/events', params=params)

        return {
            'events': [Event(**item) for item in response['data']],
            'meta': response.get('meta', {})
        }

    def get_event(self, event_id: str) -> Event:
        response = self._make_request('GET', f'/api/v1/admin/events/{event_id}')
        return Event(**response['data'])

    def create_event(self, event_data: Dict[str, Any], image_path: Optional[str] = None) -> Event:
        files = {}
        if image_path:
            files['image'] = open(image_path, 'rb')

        try:
            response = self._make_request('POST', '/api/v1/admin/events', data=event_data, files=files)
            return Event(**response['data'])
        finally:
            if files:
                files['image'].close()

    def update_event(self, event_id: str, event_data: Dict[str, Any], image_path: Optional[str] = None) -> Event:
        files = {}
        if image_path:
            files['image'] = open(image_path, 'rb')

        try:
            response = self._make_request('PUT', f'/api/v1/admin/events/{event_id}', data=event_data, files=files)
            return Event(**response['data'])
        finally:
            if files:
                files['image'].close()

    def delete_event(self, event_id: str) -> None:
        self._make_request('DELETE', f'/api/v1/admin/events/{event_id}')

    # Users Methods
    def get_users(self, page: int = 1, per_page: int = 20, search: Optional[str] = None) -> Dict[str, Any]:
        params = {'page': page, 'per_page': per_page}
        if search:
            params['search'] = search

        response = self._make_request('GET', '/api/v1/admin/users', params=params)

        return {
            'users': [User(**item) for item in response['data']],
            'meta': response.get('meta', {})
        }

# Usage Example
def example_usage():
    # Initialize client
    client = BlancakanApiClient('http://localhost:3000')

    try:
        # Sign in
        auth_result = client.sign_in('user@example.com', 'password123')
        print(f"Signed in as: {auth_result['user']['email']}")

        # Get categories
        categories = client.get_categories()
        print(f"Found {len(categories)} categories")

        # Create category
        new_category = client.create_category(
            name="Python Events",
            description="Events related to Python programming"
        )
        print(f"Created category: {new_category.name}")

        # Get events with pagination
        events_result = client.get_events(page=1, per_page=10, status='published')
        print(f"Found {len(events_result['events'])} events")
        print(f"Total pages: {events_result['meta']['total_pages']}")

        # Create event
        event_data = {
            'title': 'Python Conference 2024',
            'description': 'Annual Python developers conference',
            'start_date': '2024-04-15T09:00:00Z',
            'end_date': '2024-04-17T18:00:00Z',
            'location': 'Python Center',
            'event_type_id': 'your-event-type-id',
            'category_ids[]': new_category._id
        }

        new_event = client.create_event(event_data, image_path='path/to/image.jpg')
        print(f"Created event: {new_event.title}")

    except BlancakanApiError as e:
        print(f"API Error: {e}")
        print(f"Status Code: {e.status_code}")
        print(f"Validation Errors: {e.errors}")

if __name__ == "__main__":
    example_usage()
```

## React Integration

```typescript
// hooks/useBlancakanApi.ts
import {
  useState,
  useEffect,
  useCallback,
  createContext,
  useContext,
} from "react";
import {
  BlancakanApiClient,
  User,
  Category,
  Event,
  BlancakanApiError,
} from "../lib/blancakan-api-client";

interface ApiContextType {
  client: BlancakanApiClient;
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
  register: (
    email: string,
    password: string,
    passwordConfirmation: string
  ) => Promise<void>;
  clearError: () => void;
}

const ApiContext = createContext<ApiContextType | null>(null);

export const BlancakanApiProvider: React.FC<{
  children: React.ReactNode;
  baseURL?: string;
}> = ({ children, baseURL }) => {
  const [client] = useState(() => new BlancakanApiClient(baseURL));
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const isAuthenticated = !!user;

  useEffect(() => {
    // Load token from storage on mount
    client.loadTokenFromStorage();
    // You might want to validate the token here by making a request to get current user
  }, [client]);

  const handleApiError = useCallback((error: unknown) => {
    if (error instanceof BlancakanApiError) {
      setError(error.message);
    } else {
      setError("An unexpected error occurred");
    }
  }, []);

  const signIn = useCallback(
    async (email: string, password: string) => {
      setIsLoading(true);
      setError(null);

      try {
        const result = await client.signIn(email, password);
        setUser(result.user);
      } catch (error) {
        handleApiError(error);
        throw error;
      } finally {
        setIsLoading(false);
      }
    },
    [client, handleApiError]
  );

  const signOut = useCallback(async () => {
    setIsLoading(true);

    try {
      await client.signOut();
      setUser(null);
    } catch (error) {
      handleApiError(error);
    } finally {
      setIsLoading(false);
    }
  }, [client, handleApiError]);

  const register = useCallback(
    async (email: string, password: string, passwordConfirmation: string) => {
      setIsLoading(true);
      setError(null);

      try {
        const result = await client.register(
          email,
          password,
          passwordConfirmation
        );
        setUser(result.user);
      } catch (error) {
        handleApiError(error);
        throw error;
      } finally {
        setIsLoading(false);
      }
    },
    [client, handleApiError]
  );

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const value: ApiContextType = {
    client,
    user,
    isAuthenticated,
    isLoading,
    error,
    signIn,
    signOut,
    register,
    clearError,
  };

  return <ApiContext.Provider value={value}>{children}</ApiContext.Provider>;
};

export const useBlancakanApi = (): ApiContextType => {
  const context = useContext(ApiContext);
  if (!context) {
    throw new Error(
      "useBlancakanApi must be used within a BlancakanApiProvider"
    );
  }
  return context;
};

// Custom hooks for specific resources
export const useCategories = () => {
  const { client } = useBlancakanApi();
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchCategories = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const result = await client.getCategories();
      setCategories(result);
    } catch (error) {
      setError(
        error instanceof BlancakanApiError
          ? error.message
          : "Failed to fetch categories"
      );
    } finally {
      setLoading(false);
    }
  }, [client]);

  useEffect(() => {
    fetchCategories();
  }, [fetchCategories]);

  const createCategory = useCallback(
    async (name: string, description: string, parentId?: string) => {
      try {
        const newCategory = await client.createCategory(
          name,
          description,
          parentId
        );
        setCategories((prev) => [...prev, newCategory]);
        return newCategory;
      } catch (error) {
        setError(
          error instanceof BlancakanApiError
            ? error.message
            : "Failed to create category"
        );
        throw error;
      }
    },
    [client]
  );

  return {
    categories,
    loading,
    error,
    refetch: fetchCategories,
    createCategory,
  };
};

export const useEvents = (params?: {
  page?: number;
  per_page?: number;
  status?: string;
}) => {
  const { client } = useBlancakanApi();
  const [events, setEvents] = useState<Event[]>([]);
  const [meta, setMeta] = useState<any>({});
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchEvents = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const result = await client.getEvents(params);
      setEvents(result.events);
      setMeta(result.meta);
    } catch (error) {
      setError(
        error instanceof BlancakanApiError
          ? error.message
          : "Failed to fetch events"
      );
    } finally {
      setLoading(false);
    }
  }, [client, params]);

  useEffect(() => {
    fetchEvents();
  }, [fetchEvents]);

  return {
    events,
    meta,
    loading,
    error,
    refetch: fetchEvents,
  };
};
```

### React Components

```typescript
// components/LoginForm.tsx
import React, { useState } from "react";
import { useBlancakanApi } from "../hooks/useBlancakanApi";

export const LoginForm: React.FC = () => {
  const { signIn, isLoading, error, clearError } = useBlancakanApi();
  const [formData, setFormData] = useState({ email: "", password: "" });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();

    try {
      await signIn(formData.email, formData.password);
      // Redirect or handle successful login
    } catch (error) {
      // Error is handled by the context
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      <div>
        <label
          htmlFor="email"
          className="block text-sm font-medium text-gray-700">
          Email
        </label>
        <input
          type="email"
          id="email"
          name="email"
          value={formData.email}
          onChange={handleChange}
          required
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        />
      </div>

      <div>
        <label
          htmlFor="password"
          className="block text-sm font-medium text-gray-700">
          Password
        </label>
        <input
          type="password"
          id="password"
          name="password"
          value={formData.password}
          onChange={handleChange}
          required
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
        />
      </div>

      <button
        type="submit"
        disabled={isLoading}
        className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50">
        {isLoading ? "Signing in..." : "Sign In"}
      </button>
    </form>
  );
};

// components/EventsList.tsx
import React from "react";
import { useEvents } from "../hooks/useBlancakanApi";

export const EventsList: React.FC = () => {
  const { events, meta, loading, error, refetch } = useEvents({
    page: 1,
    per_page: 10,
  });

  if (loading) return <div>Loading events...</div>;
  if (error) return <div className="text-red-600">Error: {error}</div>;

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold">Events</h2>
        <button
          onClick={refetch}
          className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
          Refresh
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {events.map((event) => (
          <div key={event._id} className="bg-white shadow rounded-lg p-6">
            <h3 className="text-lg font-semibold mb-2">{event.title}</h3>
            <p className="text-gray-600 mb-2">{event.description}</p>
            <div className="text-sm text-gray-500">
              <p>Location: {event.location}</p>
              <p>Date: {new Date(event.start_date).toLocaleDateString()}</p>
              <p>
                Status:{" "}
                <span
                  className={`px-2 py-1 rounded text-xs ${
                    event.status === "published"
                      ? "bg-green-100 text-green-800"
                      : event.status === "draft"
                      ? "bg-yellow-100 text-yellow-800"
                      : "bg-gray-100 text-gray-800"
                  }`}>
                  {event.status}
                </span>
              </p>
            </div>
          </div>
        ))}
      </div>

      {meta.total_pages > 1 && (
        <div className="flex justify-center space-x-2">
          <span>
            Page {meta.current_page} of {meta.total_pages}
          </span>
          {/* Add pagination controls here */}
        </div>
      )}
    </div>
  );
};

// App.tsx
import React from "react";
import { BlancakanApiProvider, useBlancakanApi } from "./hooks/useBlancakanApi";
import { LoginForm } from "./components/LoginForm";
import { EventsList } from "./components/EventsList";

const AppContent: React.FC = () => {
  const { isAuthenticated, user, signOut } = useBlancakanApi();

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="max-w-md w-full space-y-8">
          <h1 className="text-3xl font-bold text-center">Blancakan Events</h1>
          <LoginForm />
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16 items-center">
            <h1 className="text-xl font-semibold">Blancakan Events</h1>
            <div className="flex items-center space-x-4">
              <span>Welcome, {user?.email}</span>
              <button
                onClick={signOut}
                className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700">
                Sign Out
              </button>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        <EventsList />
      </main>
    </div>
  );
};

function App() {
  return (
    <BlancakanApiProvider baseURL="http://localhost:3000">
      <AppContent />
    </BlancakanApiProvider>
  );
}

export default App;
```

This comprehensive SDK documentation provides complete integration examples for multiple programming languages and frameworks. Each implementation includes error handling, authentication management, and practical usage examples that developers can immediately use in their applications.
