"""
Serializers for recipe API.
"""

from core.models import (
    Recipe,
    Tag,
    Ingredient,
)
from rest_framework import serializers


class IngredientSerializer(serializers.ModelSerializer):
    """Serializer for ingredients."""

    class Meta:
        model = Ingredient
        fields = [  # noqa: RUF012
            'id',
            'name',
        ]
        read_only_fields = ['id']  # noqa: RUF012


class TagSerializer(serializers.ModelSerializer):
    """Serializer for recipe tags."""

    class Meta:
        model = Tag
        fields = [  # noqa: RUF012
            'id',
            'name'
        ]
        read_only_fields = ['id']  # noqa: RUF012


class RecipeSerializer(serializers.ModelSerializer):
    """Serializer for recipes."""
    tags = TagSerializer(many=True, required=False)

    class Meta:
        model = Recipe
        fields = [  # noqa: RUF012
            'id',
            'title',
            'time_minutes',
            'price',
            'link',
            'tags'
        ]
        read_only_fields = ['id']  # noqa: RUF012

    def _get_or_create_tags(self, tags, recipe):
        """Handle getting or creating tags as needed."""
        auth_user = self.context['request'].user
        for tag in tags:
            tag_obj, created = Tag.objects.get_or_create(
                user=auth_user,
                **tag,
            )
            recipe.tags.add(tag_obj)

    def create(self, validated_data):
        """Create a recipe."""
        tags = validated_data.pop('tags', [])
        recipe = Recipe.objects.create(**validated_data)
        self._get_or_create_tags(tags, recipe)

        return recipe

    def update(self, instance, validated_data):
        """Update recipe."""
        tags = validated_data.pop('tags', None)
        if tags is not None:
            instance.tags.clear()
            self._get_or_create_tags(tags, instance)

        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        instance.save()
        return instance


class RecipeDetailSerializer(RecipeSerializer):
    """Serializer for recipe detail view."""

    class Meta(RecipeSerializer.Meta):
        fields = [*RecipeSerializer.Meta.fields, 'description']  # noqa: RUF012
