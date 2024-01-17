void HandleKeysPressed ();

typUnit *CreatePerson ();
void HeroMove (int direction);
void LoadImages (GtkWidget *window);
typUnit *CreateHero ();
void HeroFire ();
void ApplyFriction ();
void LoadPixmaps (GtkWidget *widget, typSprite *sprites);
void Move (typUnit *unit);
int UnitScreenX (typUnit *unit);
void FreeDestroyedUnits ();
int GetGameHeight ();
void CollisionCheck ();
void DrawRadar (GdkPixmap *pixmap, GtkWidget *drawing_area);
void DrawScreen (GdkPixmap *pixmap, GtkWidget *drawing_area);
void DrawUnits (GdkPixmap *pixmap, GtkWidget *drawing_area);
void CalculateAdjustments (GtkWidget *drawing_area);
void DrawMountains (GdkPixmap *pixmap, GtkWidget *drawing_area, int nTop, int nBottom);
void StartGame ();
void GenerateTerrain ();
GList *AddPoint (GList *terrainList, int x, int y);
GList *AddMountain (GList *mountainList, int peakx, int peaky);
gint MountainCompare (const typMountain *m1, const typMountain *m2);
void DisplayUnits (GdkPixmap *pixmap, GtkWidget *drawing_area);
typUnit *AnyoneBetween (int x1, int y1, int x2, int y2);
typSprite *GetSprite (typUnit *unit);
void AIModule (typUnit *unit);
void AttemptFiring (typUnit *unit);
int Direction (typUnit *u1, typUnit *u2);
int DistanceBetween (typUnit *u1, typUnit *u2);
void PlaceAliens ();
typUnit *CreateMissile (typUnit *alien, typUnit *hero);
typUnit *CreateAlien ();
void PlacePeople ();
typUnit *CreatePerson ();
