/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under both the MIT license found in the
 * LICENSE-MIT file in the root directory of this source tree and the Apache
 * License, Version 2.0 found in the LICENSE-APACHE file in the root directory
 * of this source tree.
 */

use elp_base_db::salsa;

use crate::Name;

#[salsa::query_group(MinInternDatabaseStorage)]
pub trait MinInternDatabase {
    #[salsa::interned]
    fn atom(&self, name: Name) -> Atom;

    #[salsa::interned]
    fn var(&self, name: Name) -> Var;
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Atom(salsa::InternId);

impl salsa::InternKey for Atom {
    fn from_intern_id(v: salsa::InternId) -> Self {
        Atom(v)
    }

    fn as_intern_id(&self) -> salsa::InternId {
        self.0
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Var(salsa::InternId);

impl salsa::InternKey for Var {
    fn from_intern_id(v: salsa::InternId) -> Self {
        Var(v)
    }

    fn as_intern_id(&self) -> salsa::InternId {
        self.0
    }
}

impl Atom {
    pub fn as_string(&self, db: &dyn MinInternDatabase) -> String {
        db.lookup_atom(*self).to_string()
    }
}

impl Var {
    pub fn as_string(&self, db: &dyn MinInternDatabase) -> String {
        db.lookup_var(*self).to_string()
    }
}
